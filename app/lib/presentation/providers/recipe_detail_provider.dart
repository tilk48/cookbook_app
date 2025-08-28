import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';
import '../../domain/entities/recipe_entity.dart';

class RecipeDetailProvider extends ChangeNotifier {
  final MealieClient _mealieClient;

  RecipeDetailProvider({required MealieClient mealieClient})
      : _mealieClient = mealieClient;

  Recipe? _recipe;
  bool _isLoading = false;
  String? _error;
  bool _isFavorite = false;

  // Interactive features state
  double _servingMultiplier = 1.0;
  final Map<int, bool> _completedSteps = {};
  int? _originalServings;

  // Getters
  Recipe? get recipe => _recipe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFavorite => _isFavorite;

  // Computed properties
  bool get hasRecipe => _recipe != null;
  List<RecipeIngredient> get ingredients => _recipe?.recipeIngredient ?? [];
  List<RecipeInstruction> get instructions => _recipe?.recipeInstructions ?? [];
  RecipeNutrition? get nutrition => _recipe?.nutrition;
  List<RecipeNote> get notes => _recipe?.notes ?? [];
  List<RecipeAsset> get assets => _recipe?.assets ?? [];

  // Recipe timing information
  String? get totalTime => _recipe?.totalTime;
  String? get prepTime => _recipe?.prepTime;
  String? get cookTime => _recipe?.cookTime;
  String? get recipeYield => _recipe?.recipeYield;
  int? get rating => _recipe?.rating;

  // Interactive features getters
  double get servingMultiplier => _servingMultiplier;
  int get currentServings => (_originalServings != null)
      ? (_originalServings! * _servingMultiplier).round()
      : 1;
  int get originalServings => _originalServings ?? 1;
  bool get hasServingAdjustment =>
      _originalServings != null && _originalServings! > 0;

  /// Get completion status of a cooking step
  bool isStepCompleted(int stepIndex) => _completedSteps[stepIndex] ?? false;

  /// Get count of completed steps
  int get completedStepsCount =>
      _completedSteps.values.where((completed) => completed).length;

  /// Load recipe by slug
  Future<void> loadRecipe(String slug) async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      print('DEBUG: Loading recipe with slug: $slug');
      final recipe = await _mealieClient.recipes.getRecipe(slug);

      // Validate recipe data
      if (recipe.id.isEmpty || recipe.name.isEmpty) {
        throw Exception('Invalid recipe data received');
      }

      _recipe = recipe;

      // Initialize serving information
      _originalServings =
          _parseServings(recipe.recipeYield, recipe.recipeServings);
      _servingMultiplier = 1.0;
      _completedSteps.clear();

      // Set favorite status (would normally come from user preferences API)
      _isFavorite = false; // Placeholder - implement user favorites later

      print('DEBUG: Recipe loaded successfully: ${recipe.name}');
      print('DEBUG: Recipe ID: ${recipe.id}');
      print(
          'DEBUG: Recipe has ${ingredients.length} ingredients and ${instructions.length} instructions');
      print('DEBUG: Recipe totalTime: ${recipe.totalTime}');
      print('DEBUG: Recipe prepTime: ${recipe.prepTime}');
      print('DEBUG: Recipe cookTime: ${recipe.cookTime}');

      _setLoading(false);
      notifyListeners();
    } catch (e, stackTrace) {
      print('DEBUG: Error loading recipe: $e');
      print('DEBUG: Stack trace: $stackTrace');
      _setError('Failed to load recipe: ${e.toString()}');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (_recipe == null) return;

    // Optimistically update UI
    _isFavorite = !_isFavorite;
    notifyListeners();

    // TODO: Implement API call to update favorite status
    // This would require a user favorites endpoint in Mealie
    try {
      // await _mealieClient.users.updateFavoriteRecipe(_recipe!.slug, _isFavorite);
      print(
          'DEBUG: Toggled favorite status for ${_recipe!.name}: $_isFavorite');
    } catch (e) {
      // Revert on error
      _isFavorite = !_isFavorite;
      notifyListeners();
      print('DEBUG: Error updating favorite status: $e');
    }
  }

  /// Clear the current recipe (useful when navigating away)
  void clearRecipe() {
    _recipe = null;
    _error = null;
    _isLoading = false;
    _isFavorite = false;
    _servingMultiplier = 1.0;
    _completedSteps.clear();
    _originalServings = null;
    notifyListeners();
  }

  /// Set target number of servings
  void setTargetServings(int targetServings) {
    if (targetServings > 0 &&
        targetServings <= 50 &&
        _originalServings != null &&
        _originalServings! > 0) {
      _servingMultiplier = targetServings / _originalServings!;
      notifyListeners();
    }
  }

  /// Increase target servings by 1
  void increaseServings() {
    final newTarget = currentServings + 1;
    if (newTarget <= 50) {
      setTargetServings(newTarget);
    }
  }

  /// Decrease target servings by 1 (minimum 1)
  void decreaseServings() {
    final newTarget = currentServings - 1;
    if (newTarget >= 1) {
      setTargetServings(newTarget);
    }
  }

  /// Toggle completion status of a cooking step
  void toggleStepCompletion(int stepIndex) {
    _completedSteps[stepIndex] = !(_completedSteps[stepIndex] ?? false);
    notifyListeners();
  }

  /// Mark all steps as completed or uncompleted
  void toggleAllSteps(bool completed) {
    for (int i = 0; i < instructions.length; i++) {
      _completedSteps[i] = completed;
    }
    notifyListeners();
  }

  /// Reset all step completions
  void resetStepCompletions() {
    _completedSteps.clear();
    notifyListeners();
  }

  /// Get formatted ingredient text with optional scaling
  String getFormattedIngredient(RecipeIngredient ingredient,
      {bool scaled = false}) {
    final parts = <String>[];

    try {
      // Add quantity and unit
      if (ingredient.quantity != null &&
          !(ingredient.disable_amount ?? false)) {
        double quantity = ingredient.quantity!;

        // Apply scaling if requested
        if (scaled && _servingMultiplier != 1.0) {
          quantity = quantity * _servingMultiplier;
        }
        if (quantity > 0) {
          final formattedQuantity = _formatQuantity(quantity);
          parts.add(formattedQuantity);
        }

        if (ingredient.unit?.name.isNotEmpty == true) {
          // Use abbreviation if available and preferred
          final unitName = (ingredient.unit!.useAbbreviation == true &&
                  ingredient.unit!.abbreviation?.isNotEmpty == true)
              ? ingredient.unit!.abbreviation!
              : ingredient.unit!.name;
          parts.add(unitName);
        }
      }

      // Add food/ingredient name
      if (ingredient.food?.name.isNotEmpty == true) {
        parts.add(ingredient.food!.name);
      }

      // Add note if present
      if (ingredient.note?.isNotEmpty == true) {
        parts.add('(${ingredient.note!})');
      }

      // If we have no formatted parts, try display text first, then original text
      if (parts.isEmpty) {
        if (ingredient.display?.isNotEmpty == true) {
          return ingredient.display!;
        }
        if (ingredient.originalText?.isNotEmpty == true) {
          return ingredient.originalText!;
        }
        return 'Ingredient';
      }

      return parts.join(' ');
    } catch (e) {
      print('DEBUG: Error formatting ingredient: $e');
      return ingredient.originalText ?? 'Ingredient';
    }
  }

  /// Check if ingredient has adjustable quantities
  bool ingredientHasQuantity(RecipeIngredient ingredient) {
    return ingredient.quantity != null &&
        ingredient.quantity! > 0 &&
        !(ingredient.disable_amount ?? false);
  }

  /// Build image URL for recipe
  String buildImageUrl() {
    if (_recipe == null) return '';

    // Prefer explicit image URL if provided by the API
    if (_recipe!.image != null &&
        _recipe!.image!.isNotEmpty &&
        _recipe!.image!.startsWith('http')) {
      return _recipe!.image!;
    }

    final baseUrl = _mealieClient.baseUrl.endsWith('/')
        ? _mealieClient.baseUrl.substring(0, _mealieClient.baseUrl.length - 1)
        : _mealieClient.baseUrl;

    // Always use standard Mealie media URL format
    return '$baseUrl/api/media/recipes/${_recipe!.id}/images/original.webp';
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _error = error;
  }

  /// Parse serving information from recipe yield string and servings field
  int? _parseServings(String? yieldString, double? servingsDouble) {
    // First try to use the recipeServings field which is more reliable
    if (servingsDouble != null && servingsDouble > 0) {
      return servingsDouble.round();
    }

    // Fallback to parsing yield string
    if (yieldString != null && yieldString.isNotEmpty) {
      // Try to extract number from yield string
      final match = RegExp(r'(\d+)').firstMatch(yieldString.toLowerCase());
      if (match != null) {
        return int.tryParse(match.group(1) ?? '');
      }
    }

    return null;
  }

  /// Format quantity for display (handle fractions nicely)
  String _formatQuantity(double quantity) {
    // Handle common fractions
    if (quantity == 0.25) return '1/4';
    if (quantity == 0.33 || (quantity - 0.33).abs() < 0.01) return '1/3';
    if (quantity == 0.5) return '1/2';
    if (quantity == 0.67 || (quantity - 0.67).abs() < 0.01) return '2/3';
    if (quantity == 0.75) return '3/4';

    // Handle mixed numbers (like 1.5 = 1 1/2)
    final whole = quantity.floor();
    final fraction = quantity - whole;

    if (fraction == 0) {
      return whole.toString();
    } else if (fraction == 0.5 && whole > 0) {
      return '$whole 1/2';
    } else if (fraction == 0.25 && whole > 0) {
      return '$whole 1/4';
    } else if (fraction == 0.75 && whole > 0) {
      return '$whole 3/4';
    }

    // Default to decimal representation with reasonable precision
    if (quantity == quantity.floor()) {
      return quantity.floor().toString();
    } else {
      return quantity
          .toStringAsFixed(quantity.truncateToDouble() == quantity ? 0 : 2);
    }
  }
}
