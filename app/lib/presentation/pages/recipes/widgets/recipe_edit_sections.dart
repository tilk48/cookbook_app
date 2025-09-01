import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealie_api/mealie_api.dart';
import '../../../providers/recipe_create_provider.dart';
import 'ingredient_item.dart';
import 'instruction_item.dart';
import 'tag_category_selector.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class BasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const BasicInfoSection({
    super.key,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Basic Information',
      icon: Icons.info_outline,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Recipe Name *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Recipe name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

class ImageSection extends StatelessWidget {
  final RecipeCreateProvider provider;

  const ImageSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Recipe Image',
      icon: Icons.image_outlined,
      child: Column(
        children: [
          if (provider.imageFile != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    provider.imageFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => provider.updateImageFile(null),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No image selected',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        provider.updateImageFile(File(image.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }
}

class TimingSection extends StatelessWidget {
  final TextEditingController totalTimeController;
  final TextEditingController prepTimeController;
  final TextEditingController cookTimeController;
  final TextEditingController servingsController;

  const TimingSection({
    super.key,
    required this.totalTimeController,
    required this.prepTimeController,
    required this.cookTimeController,
    required this.servingsController,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Timing & Servings',
      icon: Icons.access_time,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: totalTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Total Time',
                    hintText: 'PT30M (30 minutes)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: servingsController,
                  decoration: const InputDecoration(
                    labelText: 'Servings',
                    hintText: '4',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: prepTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Prep Time',
                    hintText: 'PT10M',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: cookTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Cook Time',
                    hintText: 'PT20M',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class IngredientsSection extends StatelessWidget {
  final RecipeCreateProvider provider;

  const IngredientsSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Ingredients (${provider.ingredients.length})',
      icon: Icons.list_alt,
      child: Column(
        children: [
          ...provider.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            return IngredientItem(
              key: ValueKey('ingredient_$index'),
              ingredient: ingredient,
              onChanged: (updated) => provider.updateIngredient(index, updated),
              onRemoved: () => provider.removeIngredient(index),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: provider.addIngredient,
            icon: const Icon(Icons.add),
            label: const Text('Add Ingredient'),
          ),
        ],
      ),
    );
  }
}

class InstructionsSection extends StatelessWidget {
  final RecipeCreateProvider provider;

  const InstructionsSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Instructions (${provider.instructions.length})',
      icon: Icons.format_list_numbered,
      child: Column(
        children: [
          ...provider.instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return InstructionItem(
              key: ValueKey('instruction_$index'),
              index: index,
              instruction: instruction,
              onChanged: (updated) => provider.updateInstruction(index, updated),
              onRemoved: () => provider.removeInstruction(index),
            );
          }),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: provider.addInstruction,
            icon: const Icon(Icons.add),
            label: const Text('Add Instruction'),
          ),
        ],
      ),
    );
  }
}

class TagsCategoriesSection extends StatelessWidget {
  final RecipeCreateProvider provider;

  const TagsCategoriesSection({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Tags & Categories',
      icon: Icons.label_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Tags
          if (provider.tags.isNotEmpty) ...[
            Text('Selected Tags:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: provider.tags.map((tag) => Chip(
                label: Text(tag.name),
                onDeleted: () => provider.removeTag(tag.id),
                deleteIconColor: Theme.of(context).colorScheme.error,
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Selected Categories
          if (provider.categories.isNotEmpty) ...[
            Text('Selected Categories:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: provider.categories.map((category) => Chip(
                label: Text(category.name),
                onDeleted: () => provider.removeCategory(category.id),
                deleteIconColor: Theme.of(context).colorScheme.error,
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Add buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showTagSelector(context),
                  icon: const Icon(Icons.local_offer),
                  label: const Text('Add Tags'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCategorySelector(context),
                  icon: const Icon(Icons.category),
                  label: const Text('Add Categories'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTagSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TagCategorySelector(
        title: 'Select Tags',
        items: provider.availableTags,
        selectedItems: provider.tags,
        onItemToggled: (tag, isSelected) {
          if (isSelected) {
            provider.addTag(tag);
          } else {
            provider.removeTag(tag.id);
          }
        },
      ),
    );
  }

  void _showCategorySelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TagCategorySelector(
        title: 'Select Categories',
        items: provider.availableCategories,
        selectedItems: provider.categories,
        onItemToggled: (category, isSelected) {
          if (isSelected) {
            provider.addCategory(category);
          } else {
            provider.removeCategory(category.id);
          }
        },
      ),
    );
  }
}
