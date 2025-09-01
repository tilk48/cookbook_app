import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';
import 'package:dio/dio.dart' as dio;
import 'package:uuid/uuid.dart';

/// Provider for managing recipe creation and editing state
class RecipeCreateProvider extends ChangeNotifier {
  final MealieClient _client;
  final Uuid _uuid = const Uuid();
  
  RecipeCreateProvider({required MealieClient mealieClient}) : _client = mealieClient;

  // Loading states
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  // Recipe data
  Recipe? _originalRecipe; // For editing existing recipes
  String _name = '';
  String _description = '';
  List<RecipeIngredient> _ingredients = [];
  List<RecipeInstruction> _instructions = [];
  String? _totalTime;
  String? _prepTime;
  String? _cookTime;
  double? _recipeServings;
  List<RecipeTag> _tags = [];
  List<RecipeCategory> _categories = [];
  File? _imageFile;

  // Import states
  bool _isImportingFromUrl = false;
  bool _isImportingFromImage = false;
  String? _importUrl;
  List<File> _importImages = [];

  // Available options
  List<RecipeTag> _availableTags = [];
  List<RecipeCategory> _availableCategories = [];
  List<IngredientUnit> _availableUnits = [];
  List<IngredientFood> _availableFoods = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  bool get isEditingMode => _originalRecipe != null;
  
  String get name => _name;
  String get description => _description;
  List<RecipeIngredient> get ingredients => _ingredients;
  List<RecipeInstruction> get instructions => _instructions;
  String? get totalTime => _totalTime;
  String? get prepTime => _prepTime;
  String? get cookTime => _cookTime;
  double? get recipeServings => _recipeServings;
  List<RecipeTag> get tags => _tags;
  List<RecipeCategory> get categories => _categories;
  File? get imageFile => _imageFile;

  bool get isImportingFromUrl => _isImportingFromUrl;
  bool get isImportingFromImage => _isImportingFromImage;
  String? get importUrl => _importUrl;
  List<File> get importImages => _importImages;

  List<RecipeTag> get availableTags => _availableTags;
  List<RecipeCategory> get availableCategories => _availableCategories;
  List<IngredientUnit> get availableUnits => _availableUnits;
  List<IngredientFood> get availableFoods => _availableFoods;

  /// Initialize for creating a new recipe
  void initializeForCreation() {
    _clearAllData();
    _loadAvailableOptions();
  }

  /// Initialize for editing an existing recipe
  void initializeForEditing(Recipe recipe) {
    _originalRecipe = recipe;
    _populateFromRecipe(recipe);
    _loadAvailableOptions();
  }

  /// Initialize from URL import
  Future<void> initializeFromUrlImport(String url) async {
    _clearAllData();
    _importUrl = url;
    _isImportingFromUrl = true;
    notifyListeners();

    try {
      _setLoading(true);
      
      // Call the URL import endpoint
      final response = await _client.dio.post(
        '/api/recipes/create/url',
        data: {'url': url},
        options: dio.Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 201 && response.data is String) {
        // Fetch the created recipe
        final createdRecipe = await _client.recipes.getRecipe(response.data);
        _populateFromRecipe(createdRecipe);
      } else {
        throw Exception('Failed to import recipe from URL');
      }
      
      await _loadAvailableOptions();
      
    } catch (e) {
      _setError('Failed to import recipe: $e');
    } finally {
      _setLoading(false);
      _isImportingFromUrl = false;
      notifyListeners();
    }
  }

  /// Initialize from image import
  Future<void> initializeFromImageImport(List<File> images, {String? translateLanguage}) async {
    _clearAllData();
    _importImages = images;
    _isImportingFromImage = true;
    notifyListeners();

    try {
      _setLoading(true);
      
      // Prepare multipart form data
      final formData = dio.FormData();
      for (final image in images) {
        formData.files.add(MapEntry(
          'images',
          await dio.MultipartFile.fromFile(image.path),
        ));
      }

      // Call the image import endpoint
      final response = await _client.dio.post(
        '/api/recipes/create/image',
        data: formData,
        queryParameters: translateLanguage != null ? {'translateLanguage': translateLanguage} : null,
      );

      if (response.statusCode == 201 && response.data is String) {
        // Fetch the created recipe
        final createdRecipe = await _client.recipes.getRecipe(response.data);
        _populateFromRecipe(createdRecipe);
      } else {
        throw Exception('Failed to import recipe from images');
      }
      
      await _loadAvailableOptions();
      
    } catch (e) {
      _setError('Failed to import recipe from images: $e');
    } finally {
      _setLoading(false);
      _isImportingFromImage = false;
      notifyListeners();
    }
  }

  /// Update recipe fields
  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateTotalTime(String? value) {
    _totalTime = value;
    notifyListeners();
  }

  void updatePrepTime(String? value) {
    _prepTime = value;
    notifyListeners();
  }

  void updateCookTime(String? value) {
    _cookTime = value;
    notifyListeners();
  }

  void updateServings(double? value) {
    _recipeServings = value;
    notifyListeners();
  }

  void updateImageFile(File? file) {
    _imageFile = file;
    notifyListeners();
  }

  /// Ingredient management
  void addIngredient() {
    _ingredients.add(const RecipeIngredient(
      quantity: 1.0,
      unit: null,
      food: null,
      originalText: '',
    ));
    notifyListeners();
  }

  void updateIngredient(int index, RecipeIngredient ingredient) {
    if (index >= 0 && index < _ingredients.length) {
      _ingredients[index] = ingredient;
      notifyListeners();
    }
  }

  void removeIngredient(int index) {
    if (index >= 0 && index < _ingredients.length) {
      _ingredients.removeAt(index);
      notifyListeners();
    }
  }

  /// Instruction management
  void addInstruction() {
    _instructions.add(const RecipeInstruction(
      id: null,
      title: '',
      text: '',
    ));
    notifyListeners();
  }

  void updateInstruction(int index, RecipeInstruction instruction) {
    if (index >= 0 && index < _instructions.length) {
      _instructions[index] = instruction;
      notifyListeners();
    }
  }

  void removeInstruction(int index) {
    if (index >= 0 && index < _instructions.length) {
      _instructions.removeAt(index);
      notifyListeners();
    }
  }

  /// Tag and category management
  void addTag(RecipeTag tag) {
    if (!_tags.any((t) => t.id == tag.id)) {
      _tags.add(tag);
      notifyListeners();
    }
  }

  void removeTag(String tagId) {
    _tags.removeWhere((tag) => tag.id == tagId);
    notifyListeners();
  }

  void addCategory(RecipeCategory category) {
    if (!_categories.any((c) => c.id == category.id)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  void removeCategory(String categoryId) {
    _categories.removeWhere((category) => category.id == categoryId);
    notifyListeners();
  }

  /// Save recipe using Mealie's two-step process
  Future<String?> saveRecipe() async {
    if (_name.trim().isEmpty) {
      _setError('Recipe name is required');
      return null;
    }

    try {
      _setSaving(true);
      
      String recipeSlug;
      if (isEditingMode) {
        // Update existing recipe with full Recipe object
        final fullRecipe = _buildFullRecipeObject();
        await _client.dio.put(
          '/api/recipes/${_originalRecipe!.slug}',
          data: fullRecipe,
          options: dio.Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );
        recipeSlug = _originalRecipe!.slug;
      } else {
        // Step 1: Create minimal recipe with just the name
        final minimalRecipe = {'name': _name.trim()};
        final createResponse = await _client.dio.post(
          '/api/recipes',
          data: minimalRecipe,
          options: dio.Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );
        
        if (createResponse.statusCode == 201 && createResponse.data is String) {
          recipeSlug = createResponse.data;
          
          // Step 2: Fetch the created recipe to get all required IDs
          final fetchResponse = await _client.dio.get('/api/recipes/$recipeSlug');
          final fetchedRecipeData = fetchResponse.data as Map<String, dynamic>;
          
          // Step 3: Update the fetched recipe with our user data
          fetchedRecipeData['name'] = _name.trim();
          fetchedRecipeData['description'] = _description.trim().isEmpty ? null : _description.trim();
          fetchedRecipeData['recipeServings'] = _recipeServings ?? 1;
          fetchedRecipeData['totalTime'] = _totalTime;
          fetchedRecipeData['prepTime'] = _prepTime;
          fetchedRecipeData['cookTime'] = _cookTime;
          fetchedRecipeData['performTime'] = _prepTime;
          fetchedRecipeData['updatedAt'] = DateTime.now().toIso8601String();
          
          // Update categories and tags
          fetchedRecipeData['recipeCategory'] = _categories.map((category) => {
            'id': category.id,
            'name': category.name,
            'slug': category.slug,
          }).toList();
          fetchedRecipeData['tags'] = _tags.map((tag) => {
            'id': tag.id,
            'name': tag.name,
            'slug': tag.slug,
          }).toList();
          
          // Update ingredients with proper structure
          fetchedRecipeData['recipeIngredient'] = _ingredients.map((ingredient) => {
            'quantity': ingredient.quantity?.toString() ?? '',
            'unit': ingredient.unit?.toJson(),
            'food': ingredient.food?.toJson(),
            'note': ingredient.note ?? '',
            'display': ingredient.originalText ?? '',
            'title': ingredient.title,
            'originalText': ingredient.originalText,
            'referenceId': _generateTempId(),
          }).toList();
          
          // Update instructions
          fetchedRecipeData['recipeInstructions'] = _instructions.map((instruction) => {
            'id': _generateTempId(),
            'title': instruction.title ?? '',
            'summary': '',
            'text': instruction.text ?? '',
            'ingredientReferences': <String>[],
          }).toList();

          await _client.dio.put(
            '/api/recipes/$recipeSlug',
            data: fetchedRecipeData,
            options: dio.Options(
              headers: {'Content-Type': 'application/json'},
            ),
          );
        } else {
          throw Exception('Failed to create recipe');
        }
      }

      // Upload image if provided
      if (_imageFile != null) {
        await _uploadRecipeImage(recipeSlug);
      }

      _clearError();
      return recipeSlug;
      
    } catch (e) {
      _setError('Failed to save recipe: $e');
      return null;
    } finally {
      _setSaving(false);
    }
  }

  /// Private methods
  void _clearAllData() {
    _originalRecipe = null;
    _name = '';
    _description = '';
    _ingredients.clear();
    _instructions.clear();
    _totalTime = null;
    _prepTime = null;
    _cookTime = null;
    _recipeServings = null;
    _tags.clear();
    _categories.clear();
    _imageFile = null;
    _importUrl = null;
    _importImages.clear();
    _clearError();
    notifyListeners();
  }

  void _populateFromRecipe(Recipe recipe) {
    _name = recipe.name;
    _description = recipe.description ?? '';
    _ingredients = List.from(recipe.recipeIngredient ?? []);
    _instructions = List.from(recipe.recipeInstructions ?? []);
    _totalTime = recipe.totalTime;
    _prepTime = recipe.prepTime;
    _cookTime = recipe.cookTime;
    _recipeServings = recipe.recipeServings;
    _tags = List.from(recipe.tags ?? []);
    _categories = List.from(recipe.recipeCategory ?? []);
    notifyListeners();
  }

  Recipe _buildRecipeObject() {
    return Recipe(
      id: _originalRecipe?.id ?? '',
      name: _name.trim(),
      slug: _originalRecipe?.slug ?? _name.toLowerCase().replaceAll(' ', '-'),
      description: _description.trim().isEmpty ? null : _description.trim(),
      recipeIngredient: _ingredients.isEmpty ? null : _ingredients,
      recipeInstructions: _instructions.isEmpty ? null : _instructions,
      totalTime: _totalTime,
      prepTime: _prepTime,
      cookTime: _cookTime,
      recipeServings: _recipeServings,
      tags: _tags.isEmpty ? null : _tags,
      recipeCategory: _categories.isEmpty ? null : _categories,
    );
  }

  /// Build full recipe object for PUT requests using fetched recipe as base
  Map<String, dynamic> _buildFullRecipeObjectWithIds(Recipe fetchedRecipe) {
    // Start with the fetched recipe and override with user input
    final recipe = <String, dynamic>{
      'id': fetchedRecipe.id,
      'name': _name.trim(),
      'slug': fetchedRecipe.slug,
      'recipeServings': _recipeServings ?? 1,
      'recipeYieldQuantity': 0,
      'recipeYield': null,
      'totalTime': _totalTime,
      'prepTime': _prepTime,
      'cookTime': _cookTime,
      'performTime': _prepTime, // Usually same as prep time
      'description': _description.trim().isEmpty ? null : _description.trim(),
      'rating': fetchedRecipe.rating,
      'orgURL': null,
      'image': null,
      'dateAdded': fetchedRecipe.dateAdded?.toIso8601String(),
      'dateUpdated': DateTime.now().toIso8601String(),
      'createdAt': fetchedRecipe.createdAt?.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    // Add categories as full objects
    if (_categories.isNotEmpty) {
      recipe['recipeCategory'] = _categories.map((category) => {
        'id': category.id,
        'name': category.name,
        'slug': category.slug,
      }).toList();
    } else {
      recipe['recipeCategory'] = <Map<String, dynamic>>[];
    }

    // Add tags as full objects
    if (_tags.isNotEmpty) {
      recipe['tags'] = _tags.map((tag) => {
        'id': tag.id,
        'name': tag.name,
        'slug': tag.slug,
      }).toList();
    } else {
      recipe['tags'] = <Map<String, dynamic>>[];
    }

    // Add ingredients with full unit/food objects
    if (_ingredients.isNotEmpty) {
      recipe['recipeIngredient'] = _ingredients.map((ingredient) => {
        'quantity': ingredient.quantity?.toString() ?? '',
        'unit': ingredient.unit != null ? {
          'id': ingredient.unit!.id.isEmpty ? _generateTempId() : ingredient.unit!.id,
          'name': ingredient.unit!.name,
          'pluralName': ingredient.unit!.name,
          'description': '',
          'extras': <String, dynamic>{},
          'fraction': true,
          'abbreviation': ingredient.unit!.abbreviation ?? ingredient.unit!.name.substring(0, 1),
          'pluralAbbreviation': null,
          'useAbbreviation': false,
          'aliases': <String>[],
        } : null,
        'food': ingredient.food != null ? {
          'id': ingredient.food!.id.isEmpty ? _generateTempId() : ingredient.food!.id,
          'name': ingredient.food!.name,
          'pluralName': null,
          'description': '',
          'extras': <String, dynamic>{},
          'labelId': null,
          'aliases': <String>[],
          'householdsWithIngredientFood': <String>[],
          'label': null,
        } : null,
        'note': ingredient.note ?? '',
        'display': ingredient.originalText ?? '',
        'title': ingredient.title,
        'originalText': ingredient.originalText,
        'referenceId': _generateTempId(),
      }).toList();
    } else {
      recipe['recipeIngredient'] = <Map<String, dynamic>>[];
    }

    // Add instructions with full objects
    if (_instructions.isNotEmpty) {
      recipe['recipeInstructions'] = _instructions.map((instruction) => {
        'id': _generateTempId(),
        'title': instruction.title ?? '',
        'summary': '',
        'text': instruction.text ?? '',
        'ingredientReferences': <String>[],
      }).toList();
    } else {
      recipe['recipeInstructions'] = <Map<String, dynamic>>[];
    }

    // Add default empty objects
    recipe['tools'] = <String>[];
    recipe['nutrition'] = {
      'calories': null,
      'carbohydrateContent': null,
      'cholesterolContent': null,
      'fatContent': null,
      'fiberContent': null,
      'proteinContent': null,
      'saturatedFatContent': null,
      'sodiumContent': null,
      'sugarContent': null,
      'transFatContent': null,
      'unsaturatedFatContent': null,
    };
    recipe['settings'] = {
      'public': false,
      'showNutrition': false,
      'showAssets': false,
      'landscapeView': false,
      'disableComments': false,
      'locked': false,
    };
    recipe['assets'] = <String>[];
    recipe['notes'] = <String>[];
    recipe['extras'] = <String, dynamic>{};
    recipe['comments'] = <String>[];

    return recipe;
  }

  /// Build full recipe object for PUT requests (matching web UI format)
  Map<String, dynamic> _buildFullRecipeObject() {
    final recipe = <String, dynamic>{
      'name': _name.trim(),
      'slug': _originalRecipe?.slug ?? _name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
      'recipeServings': _recipeServings ?? 1,
      'recipeYieldQuantity': 0,
      'recipeYield': null,
      'totalTime': _totalTime,
      'prepTime': _prepTime,
      'cookTime': _cookTime,
      'performTime': _prepTime, // Usually same as prep time
      'description': _description.trim().isEmpty ? null : _description.trim(),
      'rating': null,
      'orgURL': null,
      'image': null,
    };

    // Add existing recipe fields if editing
    if (_originalRecipe != null) {
      recipe['id'] = _originalRecipe!.id;
      recipe['dateAdded'] = _originalRecipe!.dateAdded?.toIso8601String();
      recipe['dateUpdated'] = DateTime.now().toIso8601String();
      recipe['createdAt'] = _originalRecipe!.createdAt?.toIso8601String();
      recipe['updatedAt'] = DateTime.now().toIso8601String();
      recipe['rating'] = _originalRecipe!.rating;
    }

    // Add categories as full objects
    if (_categories.isNotEmpty) {
      recipe['recipeCategory'] = _categories.map((category) => {
        'id': category.id,
        'name': category.name,
        'slug': category.slug,
        // Add other fields if available
      }).toList();
    } else {
      recipe['recipeCategory'] = <Map<String, dynamic>>[];
    }

    // Add tags as full objects
    if (_tags.isNotEmpty) {
      recipe['tags'] = _tags.map((tag) => {
        'id': tag.id,
        'name': tag.name,
        'slug': tag.slug,
        // Add other fields if available
      }).toList();
    } else {
      recipe['tags'] = <Map<String, dynamic>>[];
    }

    // Add ingredients with full unit/food objects
    if (_ingredients.isNotEmpty) {
      recipe['recipeIngredient'] = _ingredients.map((ingredient) => {
        'quantity': ingredient.quantity?.toString() ?? '',
        'unit': ingredient.unit != null ? {
          'id': ingredient.unit!.id.isEmpty ? _generateTempId() : ingredient.unit!.id,
          'name': ingredient.unit!.name,
          'pluralName': ingredient.unit!.name,
          'description': '',
          'extras': <String, dynamic>{},
          'fraction': true,
          'abbreviation': ingredient.unit!.abbreviation ?? ingredient.unit!.name.substring(0, 1),
          'pluralAbbreviation': null,
          'useAbbreviation': false,
          'aliases': <String>[],
        } : null,
        'food': ingredient.food != null ? {
          'id': ingredient.food!.id.isEmpty ? _generateTempId() : ingredient.food!.id,
          'name': ingredient.food!.name,
          'pluralName': null,
          'description': '',
          'extras': <String, dynamic>{},
          'labelId': null,
          'aliases': <String>[],
          'householdsWithIngredientFood': <String>[],
          'label': null,
        } : null,
        'note': ingredient.note ?? '',
        'display': ingredient.originalText ?? '',
        'title': ingredient.title,
        'originalText': ingredient.originalText,
        'referenceId': _generateTempId(),
      }).toList();
    } else {
      recipe['recipeIngredient'] = <Map<String, dynamic>>[];
    }

    // Add instructions with full objects
    if (_instructions.isNotEmpty) {
      recipe['recipeInstructions'] = _instructions.map((instruction) => {
        'id': _generateTempId(),
        'title': instruction.title ?? '',
        'summary': '',
        'text': instruction.text ?? '',
        'ingredientReferences': <String>[],
      }).toList();
    } else {
      recipe['recipeInstructions'] = <Map<String, dynamic>>[];
    }

    // Add default empty objects
    recipe['tools'] = <String>[];
    recipe['nutrition'] = {
      'calories': null,
      'carbohydrateContent': null,
      'cholesterolContent': null,
      'fatContent': null,
      'fiberContent': null,
      'proteinContent': null,
      'saturatedFatContent': null,
      'sodiumContent': null,
      'sugarContent': null,
      'transFatContent': null,
      'unsaturatedFatContent': null,
    };
    recipe['settings'] = {
      'public': false,
      'showNutrition': false,
      'showAssets': false,
      'landscapeView': false,
      'disableComments': false,
      'locked': false,
    };
    recipe['assets'] = <String>[];
    recipe['notes'] = <String>[];
    recipe['extras'] = <String, dynamic>{};
    recipe['comments'] = <String>[];

    return recipe;
  }

  /// Generate a proper UUID v4
  String _generateTempId() {
    return _uuid.v4();
  }

  CreateRecipeRequest _buildCreateRecipeRequest() {
    return CreateRecipeRequest(
      name: _name.trim(),
      description: _description.trim().isEmpty ? null : _description.trim(),
      recipeIngredient: _ingredients.isEmpty ? null : _ingredients,
      recipeInstructions: _instructions.isEmpty ? null : _instructions.map((inst) => 
        CreateRecipeInstruction(
          title: inst.title ?? '',
          text: inst.text ?? '',
        )).toList(),
      totalTime: _totalTime?.toString(),
      prepTime: _prepTime?.toString(),
      cookTime: _cookTime?.toString(),
      recipeYield: _recipeServings?.toString(),
      tags: _tags.isEmpty ? null : _tags.map((t) => t.id).toList(),
      recipeCategory: _categories.isEmpty ? null : _categories.map((c) => c.id).toList(),
    );
  }

  Future<void> _loadAvailableOptions() async {
    try {
      // Load available tags from existing recipes (similar to RecipeProvider)
      final recipesResponse = await _client.recipes.getRecipes(
        queryParams: const QueryParameters(page: 1, perPage: 50),
      );
      
      final tagMap = <String, RecipeTag>{};
      for (final recipe in recipesResponse.items) {
        if (recipe.tags != null) {
          for (final tag in recipe.tags!) {
            tagMap[tag.id] = tag;
          }
        }
      }
      _availableTags = tagMap.values.toList();

      // Load categories
      _availableCategories = await _client.recipes.getCategories();

      // Load units
      final unitsResponse = await _client.dio.get('/api/units', queryParameters: {
        'page': 1,
        'perPage': 500, // Load many more units
      });
      if (unitsResponse.statusCode == 200) {
        final unitsData = unitsResponse.data;
        final unitsList = (unitsData['items'] as List)
            .map((unitData) => IngredientUnit.fromJson(unitData))
            .toList();
        _availableUnits = unitsList;
      }

      // Load foods
      final foodsResponse = await _client.dio.get('/api/foods', queryParameters: {
        'page': 1,
        'perPage': 500, // Load many more foods initially
      });
      if (foodsResponse.statusCode == 200) {
        final foodsData = foodsResponse.data;
        final foodsList = (foodsData['items'] as List)
            .map((foodData) => IngredientFood.fromJson(foodData))
            .toList();
        _availableFoods = foodsList;
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading available options: $e');
    }
  }

  Future<void> _uploadRecipeImage(String slug) async {
    if (_imageFile == null) return;

    try {
      // The image upload might be handled differently, but for now we'll skip it
      // as it's not critical for the core functionality
      print('Image upload for recipe $slug would be implemented here');
    } catch (e) {
      print('Failed to upload image: $e');
      // Don't fail the whole operation for image upload issues
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) _clearError();
    notifyListeners();
  }

  void _setSaving(bool saving) {
    _isSaving = saving;
    if (saving) _clearError();
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Search for units by name with pagination support
  Future<List<IngredientUnit>> searchUnits(String query, {int page = 1}) async {
    if (query.trim().isEmpty && page == 1) {
      return _availableUnits.take(50).toList();
    }

    try {
      final response = await _client.dio.get('/api/units', queryParameters: {
        'search': query.trim().isEmpty ? null : query.trim(),
        'page': page,
        'perPage': 50,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final unitsList = (data['items'] as List)
            .map((unitData) => IngredientUnit.fromJson(unitData))
            .toList();
        return unitsList;
      }
    } catch (e) {
      print('Error searching units: $e');
    }
    
    // Fallback to local filtering for first page only
    if (page == 1) {
      return _availableUnits
          .where((unit) => unit.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    
    return [];
  }

  /// Search for foods by name with pagination support
  Future<List<IngredientFood>> searchFoods(String query, {int page = 1}) async {
    if (query.trim().isEmpty && page == 1) {
      return _availableFoods.take(50).toList();
    }

    try {
      final response = await _client.dio.get('/api/foods', queryParameters: {
        'search': query.trim().isEmpty ? null : query.trim(),
        'page': page,
        'perPage': 50,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        final foodsList = (data['items'] as List)
            .map((foodData) => IngredientFood.fromJson(foodData))
            .toList();
        return foodsList;
      }
    } catch (e) {
      print('Error searching foods: $e');
    }
    
    // Fallback to local filtering for first page only
    if (page == 1) {
      return _availableFoods
          .where((food) => food.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    
    return [];
  }

  @override
  void dispose() {
    super.dispose();
  }
}