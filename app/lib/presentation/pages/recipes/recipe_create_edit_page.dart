import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../providers/recipe_create_provider.dart';
import 'recipe_edit_page.dart';

/// Initialization data for creating a recipe
class RecipeCreateInitData {
  final RecipeCreateMode mode;
  final String? importUrl;
  final List<File>? imageFiles;
  final String? translateLanguage;

  RecipeCreateInitData({
    required this.mode,
    this.importUrl,
    this.imageFiles,
    this.translateLanguage,
  });
}

enum RecipeCreateMode {
  manual,
  urlImport,
  imageImport,
}

/// Wrapper for RecipeEditPage when creating a new recipe
/// This provides the RecipeCreateProvider at the correct scope
class RecipeCreateEditPage extends StatefulWidget {
  final RecipeCreateInitData? initData;
  
  const RecipeCreateEditPage({super.key, this.initData});

  @override
  State<RecipeCreateEditPage> createState() => _RecipeCreateEditPageState();
}

class _RecipeCreateEditPageState extends State<RecipeCreateEditPage> {
  late RecipeCreateProvider _provider;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _provider = sl<RecipeCreateProvider>();
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    final initData = widget.initData;
    
    if (initData == null || initData.mode == RecipeCreateMode.manual) {
      _provider.initializeForCreation();
    } else if (initData.mode == RecipeCreateMode.urlImport && initData.importUrl != null) {
      await _provider.initializeFromUrlImport(initData.importUrl!);
    } else if (initData.mode == RecipeCreateMode.imageImport && initData.imageFiles != null) {
      await _provider.initializeFromImageImport(
        initData.imageFiles!,
        translateLanguage: initData.translateLanguage,
      );
    }
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized && _provider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Preparing recipe editor...'),
            ],
          ),
        ),
      );
    }

    if (_provider.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize recipe',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _provider.error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider<RecipeCreateProvider>.value(
      value: _provider,
      child: const RecipeEditPage(),
    );
  }
}