import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../providers/recipe_create_provider.dart';
import 'recipe_create_edit_page.dart';

class RecipeCreateEntryPage extends StatelessWidget {
  const RecipeCreateEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RecipeCreateProvider>(
      create: (_) => sl<RecipeCreateProvider>(),
      child: const _RecipeCreateEntryView(),
    );
  }
}

class _RecipeCreateEntryView extends StatefulWidget {
  const _RecipeCreateEntryView();

  @override
  State<_RecipeCreateEntryView> createState() => _RecipeCreateEntryViewState();
}

class _RecipeCreateEntryViewState extends State<_RecipeCreateEntryView> {
  final _urlController = TextEditingController();
  final _urlFormKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
        elevation: 0,
      ),
      body: Consumer<RecipeCreateProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing recipe...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'How would you like to create your recipe?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose one of the options below to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Option 1: Manual Creation
                _CreateOptionCard(
                  icon: Icons.edit_outlined,
                  title: 'Create Manually',
                  subtitle: 'Start from scratch and add your own recipe details',
                  color: Colors.blue,
                  onTap: () => _createManualRecipe(context, provider),
                ),
                const SizedBox(height: 16),

                // Option 2: Import from URL
                _CreateOptionCard(
                  icon: Icons.link_outlined,
                  title: 'Import from URL',
                  subtitle: 'Automatically extract recipe from a website',
                  color: Colors.green,
                  onTap: () => _showUrlImportDialog(context, provider),
                ),
                const SizedBox(height: 16),

                // Option 3: Import from Images
                _CreateOptionCard(
                  icon: Icons.camera_alt_outlined,
                  title: 'Import from Photos',
                  subtitle: 'Use AI to extract recipe from images',
                  color: Colors.orange,
                  onTap: () => _importFromImages(context, provider),
                ),

                if (provider.error != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _createManualRecipe(BuildContext context, RecipeCreateProvider provider) {
    context.go('/recipes/create/edit', extra: RecipeCreateInitData(
      mode: RecipeCreateMode.manual,
    ));
  }

  void _showUrlImportDialog(BuildContext context, RecipeCreateProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import from URL'),
        content: Form(
          key: _urlFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the URL of the recipe you want to import:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Recipe URL',
                  hintText: 'https://example.com/recipe',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a URL';
                  }
                  if (!value.startsWith('http://') && !value.startsWith('https://')) {
                    return 'Please enter a valid URL';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _urlController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _importFromUrl(context, provider),
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromUrl(BuildContext context, RecipeCreateProvider provider) async {
    if (_urlFormKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(); // Close dialog
      
      final url = _urlController.text.trim();
      _urlController.clear();
      
      if (context.mounted) {
        context.go('/recipes/create/edit', extra: RecipeCreateInitData(
          mode: RecipeCreateMode.urlImport,
          importUrl: url,
        ));
      }
    }
  }

  Future<void> _importFromImages(BuildContext context, RecipeCreateProvider provider) async {
    try {
      // Show picker options
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photos'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Pick images
      List<XFile> pickedFiles;
      if (source == ImageSource.camera) {
        final pickedFile = await _imagePicker.pickImage(source: source);
        pickedFiles = pickedFile != null ? [pickedFile] : [];
      } else {
        pickedFiles = await _imagePicker.pickMultiImage();
      }

      if (pickedFiles.isEmpty) return;

      // Convert to File objects
      final imageFiles = pickedFiles.map((xFile) => File(xFile.path)).toList();

      // Show language selection dialog
      String? translateLanguage;
      if (context.mounted) {
        translateLanguage = await _showLanguageDialog(context);
      }

      // Navigate to edit page with image data
      if (context.mounted) {
        context.go('/recipes/create/edit', extra: RecipeCreateInitData(
          mode: RecipeCreateMode.imageImport,
          imageFiles: imageFiles,
          translateLanguage: translateLanguage,
        ));
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  Future<String?> _showLanguageDialog(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language (Optional)'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Auto-detect'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('en'),
            child: const Text('English'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('de'),
            child: const Text('German'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('es'),
            child: const Text('Spanish'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('fr'),
            child: const Text('French'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop('it'),
            child: const Text('Italian'),
          ),
        ],
      ),
    );
  }
}

class _CreateOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CreateOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}