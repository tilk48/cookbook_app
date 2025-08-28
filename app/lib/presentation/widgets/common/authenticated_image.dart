import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class AuthenticatedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit? fit;
  final Widget Function()? placeholderBuilder;
  final Widget Function(Object error)? errorBuilder;
  // Test hook: override the image fetcher in tests to provide deterministic bytes
  static Future<Uint8List> Function(String url, Map<String, String> headers)?
      fetchOverride;

  const AuthenticatedImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  State<AuthenticatedImage> createState() => _AuthenticatedImageState();
}

class _AuthenticatedImageState extends State<AuthenticatedImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(AuthenticatedImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _imageBytes = null;
    });

    // Handle empty or invalid URLs
    if (widget.imageUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _error = Exception('Empty image URL');
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final authProvider = context.read<AuthProvider>();

      final headers = <String, String>{
        'Accept': 'image/*',
      };

      // Add authorization header if user is logged in
      if (authProvider.isLoggedIn && authProvider.accessToken != null) {
        headers['Authorization'] = 'Bearer ${authProvider.accessToken}';
      }
      // Test override path
      if (AuthenticatedImage.fetchOverride != null) {
        final bytes =
            await AuthenticatedImage.fetchOverride!(widget.imageUrl, headers);
        if (!mounted) return;
        setState(() {
          _imageBytes = bytes;
          _isLoading = false;
        });
        return;
      }

      final response =
          await http.get(Uri.parse(widget.imageUrl), headers: headers);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        // If auth request failed, try without auth (images might be public)
        if (response.statusCode == 401 || response.statusCode == 403) {
          final noAuthResponse = await http.get(Uri.parse(widget.imageUrl));

          if (!mounted) return;

          if (noAuthResponse.statusCode == 200) {
            setState(() {
              _imageBytes = noAuthResponse.bodyBytes;
              _isLoading = false;
            });
            return;
          }
        }

        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholderBuilder?.call() ??
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          widget.placeholderBuilder?.call() ??
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            ),
          );
    }

    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: widget.fit,
      );
    }

    return widget.placeholderBuilder?.call() ??
        Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.image,
              color: Colors.grey,
              size: 48,
            ),
          ),
        );
  }
}
