import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealie_api/mealie_api.dart';

import '../../providers/recipe_create_provider.dart';
import 'widgets/recipe_edit_form.dart';

class RecipeEditPage extends StatelessWidget {
  final String? recipeSlug;

  const RecipeEditPage({super.key, this.recipeSlug});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeCreateProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.isEditingMode ? 'Edit Recipe' : 'Create Recipe'),
            elevation: 0,
            actions: [
              if (provider.isSaving)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: () => _saveRecipe(context, provider),
                  child: const Text('Save'),
                ),
            ],
          ),
          body: RecipeEditForm(recipeSlug: recipeSlug),
        );
      },
    );
  }

  Future<void> _saveRecipe(BuildContext context, RecipeCreateProvider provider) async {
    final slug = await provider.saveRecipe();
    
    if (context.mounted) {
      if (slug != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.isEditingMode ? 'Recipe updated successfully!' : 'Recipe created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/recipes/$slug');
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

