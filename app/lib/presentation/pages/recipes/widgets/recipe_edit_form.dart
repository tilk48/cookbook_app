import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/recipe_create_provider.dart';
import 'recipe_edit_sections.dart';

class RecipeEditForm extends StatefulWidget {
  final String? recipeSlug;

  const RecipeEditForm({super.key, this.recipeSlug});

  @override
  State<RecipeEditForm> createState() => _RecipeEditFormState();
}

class _RecipeEditFormState extends State<RecipeEditForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalTimeController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _totalTimeController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    final provider = context.read<RecipeCreateProvider>();
    
    // Initialize controllers with current values
    _nameController.text = provider.name;
    _descriptionController.text = provider.description;
    _totalTimeController.text = provider.totalTime ?? '';
    _prepTimeController.text = provider.prepTime ?? '';
    _cookTimeController.text = provider.cookTime ?? '';
    _servingsController.text = provider.recipeServings?.toString() ?? '';

    // Set up listeners to update provider
    _nameController.addListener(() => provider.updateName(_nameController.text));
    _descriptionController.addListener(() => provider.updateDescription(_descriptionController.text));
    _totalTimeController.addListener(() => provider.updateTotalTime(_totalTimeController.text.isEmpty ? null : _totalTimeController.text));
    _prepTimeController.addListener(() => provider.updatePrepTime(_prepTimeController.text.isEmpty ? null : _prepTimeController.text));
    _cookTimeController.addListener(() => provider.updateCookTime(_cookTimeController.text.isEmpty ? null : _cookTimeController.text));
    _servingsController.addListener(() {
      final value = double.tryParse(_servingsController.text);
      provider.updateServings(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecipeCreateProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading recipe...'),
              ],
            ),
          );
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Basic Information Section
                BasicInfoSection(
                  nameController: _nameController,
                  descriptionController: _descriptionController,
                ),
                const SizedBox(height: 16),

                // Image Section
                ImageSection(provider: provider),
                const SizedBox(height: 16),

                // Timing Section
                TimingSection(
                  totalTimeController: _totalTimeController,
                  prepTimeController: _prepTimeController,
                  cookTimeController: _cookTimeController,
                  servingsController: _servingsController,
                ),
                const SizedBox(height: 16),

                // Ingredients Section
                IngredientsSection(provider: provider),
                const SizedBox(height: 16),

                // Instructions Section
                InstructionsSection(provider: provider),
                const SizedBox(height: 16),

                // Tags & Categories Section
                TagsCategoriesSection(provider: provider),

                // Bottom padding
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
}