import 'package:flutter/material.dart';
import 'package:mealie_api/mealie_api.dart';
import '../../domain/entities/recipe_entity.dart';
import '../../domain/usecases/recipes/get_recipes_usecase.dart';
import '../../domain/usecases/recipes/search_recipes_usecase.dart';
import '../../core/utils/result.dart';
import '../pages/recipes/recipe_list_page.dart';

class RecipeProvider extends ChangeNotifier {
  final GetRecipesUseCase? _getRecipesUseCase;
  final SearchRecipesUseCase? _searchRecipesUseCase;
  final MealieClient _mealieClient;

  RecipeProvider({
    GetRecipesUseCase? getRecipesUseCase,
    SearchRecipesUseCase? searchRecipesUseCase,
    required MealieClient mealieClient,
  })  : _getRecipesUseCase = getRecipesUseCase,
        _searchRecipesUseCase = searchRecipesUseCase,
        _mealieClient = mealieClient;

  List<RecipeEntity> _recipes = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final int _pageSize = 20;
  
  // Persistent filter and sort state
  String _currentQuery = '';
  List<String> _currentCategories = [];
  List<String> _currentTags = [];
  RecipeSortOption _currentSortOption = RecipeSortOption.dateUpdated;
  
  // Cached categories and tags
  List<RecipeCategory> _availableCategories = [];
  List<RecipeTag> _availableTags = [];
  bool _categoriesLoaded = false;
  bool _tagsLoaded = false;

  // Getters
  List<RecipeEntity> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  
  // Filter/Sort state getters
  String get currentQuery => _currentQuery;
  List<String> get currentCategories => List.unmodifiable(_currentCategories);
  List<String> get currentTags => List.unmodifiable(_currentTags);
  RecipeSortOption get currentSortOption => _currentSortOption;
  
  // Available options getters
  List<String> get availableCategoryNames => _availableCategories.map((c) => c.name).toList();
  List<String> get availableTagNames => _availableTags.map((t) => t.name).toList();
  List<RecipeCategory> get availableCategories => List.unmodifiable(_availableCategories);
  List<RecipeTag> get availableTags => List.unmodifiable(_availableTags);

  /// Load initial recipes
  Future<void> loadRecipes() async {
    if (_isLoading) return;

    _setLoading(true);
    _setError(null);
    _currentPage = 1;

    // Clear existing recipes to avoid stale data
    _recipes.clear();

    try {
      final orderBy = _mapSortOptionToApiField(_currentSortOption);
      final queryParams = QueryParameters(
        page: _currentPage,
        perPage: _pageSize,
        orderBy: orderBy,
        orderDirection: OrderDirection.desc,
      );

      final response =
          await _mealieClient.recipes.getRecipes(queryParams: queryParams);
      final newRecipes = response.items.map(_convertToEntity).toList();

      _recipes = newRecipes;
      _hasMore = _currentPage < response.totalPages;
      
      // Build cache for tag/category name->ID mapping
      _buildTagAndCategoryCaches();

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load recipes: ${e.toString()}');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Load more recipes for pagination
  Future<void> loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;

    _setLoading(true);
    _currentPage++;

    try {
      final orderBy = _mapSortOptionToApiField(_currentSortOption);
      final queryParams = QueryParameters(
        page: _currentPage,
        perPage: _pageSize,
        orderBy: orderBy,
        orderDirection: OrderDirection.desc,
      );

      final response =
          await _mealieClient.recipes.getRecipes(queryParams: queryParams);
      final newRecipes = response.items.map(_convertToEntity).toList();
      _recipes.addAll(newRecipes);
      _hasMore = _currentPage < response.totalPages;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load more recipes: ${e.toString()}');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Refresh recipes (pull-to-refresh)
  Future<void> refreshRecipes() async {
    _currentPage = 1;
    _hasMore = true;
    
    // If we have active filters/search, reapply them; otherwise load normally
    if (_currentQuery.isNotEmpty || _currentCategories.isNotEmpty || _currentTags.isNotEmpty || _currentSortOption != RecipeSortOption.dateUpdated) {
      await searchRecipes(
        query: _currentQuery.isNotEmpty ? _currentQuery : null,
        categories: _currentCategories.isNotEmpty ? _currentCategories : null,
        tags: _currentTags.isNotEmpty ? _currentTags : null,
        sortBy: _currentSortOption,
      );
    } else {
      await loadRecipes();
    }
  }

  /// Search recipes with filters
  Future<void> searchRecipes({
    String? query,
    List<String>? categories,
    List<String>? tags,
    dynamic sortBy,
  }) async {
    if (_isLoading) return;

    // Update stored filter state
    _currentQuery = query ?? '';
    _currentCategories = List.from(categories ?? []);
    _currentTags = List.from(tags ?? []);
    if (sortBy != null && sortBy is RecipeSortOption) {
      _currentSortOption = sortBy;
    }

    _setLoading(true);
    _setError(null);
    _currentPage = 1;

    try {
      final orderBy = _mapSortOptionToApiField(_currentSortOption);
      
      // Get tag and category IDs for API filtering
      final tagIds = await _getTagIdsFromNames(_currentTags);
      final categoryIds = await _getCategoryIdsFromNames(_currentCategories);
      
      final queryParams = QueryParameters(
        page: _currentPage,
        perPage: _pageSize,
        orderBy: orderBy,
        orderDirection: OrderDirection.desc,
        tags: tagIds.isNotEmpty ? tagIds : null,
        categories: categoryIds.isNotEmpty ? categoryIds : null,
        requireAllTags: false, // OR logic for tags
        requireAllCategories: false, // OR logic for categories
      );

      print('DEBUG: Searching with - query: "$_currentQuery", categories: $_currentCategories, tags: $_currentTags, sortBy: $_currentSortOption');
      print('DEBUG: Mapped orderBy: $orderBy');
      print('DEBUG: Tag IDs: $tagIds');
      print('DEBUG: Category IDs: $categoryIds');

      PaginatedResponse<RecipeSummary> response;

      if (_currentQuery.isNotEmpty) {
        response = await _mealieClient.recipes.searchRecipes(
          query: _currentQuery,
          queryParams: queryParams,
        );
      } else {
        response =
            await _mealieClient.recipes.getRecipes(queryParams: queryParams);
      }

      print('DEBUG: API returned ${response.items.length} recipes (with server-side filtering)');

      // No more client-side filtering needed - API does it all!
      final recipes = response.items.map(_convertToEntity).toList();
      
      _recipes = recipes;
      
      // Build cache for future filtering
      _buildTagAndCategoryCaches();
      
      // Normal pagination works now since filtering is done server-side
      _hasMore = _currentPage < response.totalPages;

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to search recipes: ${e.toString()}');
      _setLoading(false);
      notifyListeners();
    }
  }

  /// Toggle recipe favorite status
  Future<void> toggleFavorite(String recipeId) async {
    final recipeIndex = _recipes.indexWhere((r) => r.id == recipeId);
    if (recipeIndex != -1) {
      _recipes[recipeIndex] = _recipes[recipeIndex].copyWith(
        isFavorite: !_recipes[recipeIndex].isFavorite,
      );
      notifyListeners();

      // Here you would call the API to update the favorite status
      // await _updateFavoriteUseCase(recipeId, _recipes[recipeIndex].isFavorite);
    }
  }

  /// Get recipe by slug
  RecipeEntity? getRecipeBySlug(String slug) {
    try {
      return _recipes.firstWhere((recipe) => recipe.slug == slug);
    } catch (e) {
      return null;
    }
  }

  /// Clear all recipes
  void clearRecipes() {
    _recipes.clear();
    _error = null;
    _isLoading = false;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  /// Load available categories from API
  Future<void> loadCategories() async {
    if (_categoriesLoaded) return;
    
    try {
      _availableCategories = await _mealieClient.recipes.getCategories();
      _categoriesLoaded = true;
      
      // Update category name to ID cache
      _categoryNameToIdCache.clear();
      for (final category in _availableCategories) {
        _categoryNameToIdCache[category.name] = category.id;
      }
      
      notifyListeners();
    } catch (e) {
      print('DEBUG: Failed to load categories: $e');
    }
  }

  /// Load available tags from API (extract from recipes since tags endpoint is complex)
  Future<void> loadTags() async {
    if (_tagsLoaded) return;
    
    try {
      // Get a larger sample of recipes to extract all possible tags
      final response = await _mealieClient.recipes.getRecipes(
        queryParams: const QueryParameters(page: 1, perPage: 100),
      );
      
      final tagMap = <String, RecipeTag>{};
      for (final recipe in response.items) {
        if (recipe.tags != null) {
          for (final tag in recipe.tags!) {
            tagMap[tag.id] = tag;
          }
        }
      }
      
      _availableTags = tagMap.values.toList()..sort((a, b) => a.name.compareTo(b.name));
      _tagsLoaded = true;
      
      // Update tag name to ID cache
      _tagNameToIdCache.clear();
      for (final tag in _availableTags) {
        _tagNameToIdCache[tag.name] = tag.id;
      }
      
      notifyListeners();
    } catch (e) {
      print('DEBUG: Failed to load tags: $e');
    }
  }

  /// Get all available categories from loaded recipes (deprecated - use loadCategories instead)
  @Deprecated('Use availableCategoryNames getter after calling loadCategories()')
  List<String> getAvailableCategories() {
    final categories = <String>{};
    for (final recipe in _recipes) {
      for (final category in recipe.categories) {
        categories.add(category.name);
      }
    }
    return categories.toList()..sort();
  }

  /// Get all available tags from loaded recipes (deprecated - use loadTags instead)
  @Deprecated('Use availableTagNames getter after calling loadTags()')
  List<String> getAvailableTags() {
    final tags = <String>{};
    for (final recipe in _recipes) {
      for (final tag in recipe.tags) {
        tags.add(tag.name);
      }
    }
    return tags.toList()..sort();
  }

  /// Cache for tag name -> ID mapping to avoid repeated API calls
  final Map<String, String> _tagNameToIdCache = {};
  final Map<String, String> _categoryNameToIdCache = {};
  
  /// Get tag IDs from tag names for API filtering
  Future<List<String>> _getTagIdsFromNames(List<String> tagNames) async {
    if (tagNames.isEmpty) return [];
    
    final tagIds = <String>[];
    
    for (final tagName in tagNames) {
      if (_tagNameToIdCache.containsKey(tagName)) {
        tagIds.add(_tagNameToIdCache[tagName]!);
      } else {
        // Need to get tag ID from API - for now, skip unknown tags
        print('DEBUG: Unknown tag name: $tagName (no ID cached)');
      }
    }
    
    return tagIds;
  }
  
  /// Get category IDs from category names for API filtering
  Future<List<String>> _getCategoryIdsFromNames(List<String> categoryNames) async {
    if (categoryNames.isEmpty) return [];
    
    final categoryIds = <String>[];
    
    for (final categoryName in categoryNames) {
      if (_categoryNameToIdCache.containsKey(categoryName)) {
        categoryIds.add(_categoryNameToIdCache[categoryName]!);
      } else {
        // Need to get category ID from API - for now, skip unknown categories
        print('DEBUG: Unknown category name: $categoryName (no ID cached)');
      }
    }
    
    return categoryIds;
  }
  
  /// Build cache of tag/category names to IDs from loaded recipes
  void _buildTagAndCategoryCaches() {
    _tagNameToIdCache.clear();
    _categoryNameToIdCache.clear();
    
    for (final recipe in _recipes) {
      for (final tag in recipe.tags) {
        _tagNameToIdCache[tag.name] = tag.id;
      }
      for (final category in recipe.categories) {
        _categoryNameToIdCache[category.name] = category.id;
      }
    }
    
    print('DEBUG: Built caches - ${_tagNameToIdCache.length} tags, ${_categoryNameToIdCache.length} categories');
  }

  // Private helper methods
  String _mapSortOptionToApiField(dynamic sortBy) {
    if (sortBy == null) return 'date_updated';

    print('DEBUG: Mapping sort option: $sortBy (type: ${sortBy.runtimeType})');

    // Handle enum directly
    if (sortBy is RecipeSortOption) {
      switch (sortBy) {
        case RecipeSortOption.name:
          return 'name';
        case RecipeSortOption.dateAdded:
          return 'date_added';
        case RecipeSortOption.dateUpdated:
          return 'date_updated';
        case RecipeSortOption.rating:
          return 'rating';
        case RecipeSortOption.cookTime:
          return 'cook_time';
      }
    }

    // Handle string inputs as fallback
    final sortString = sortBy.toString().toLowerCase();
    switch (sortString) {
      case 'recipesortOption.name':
      case 'name':
        return 'name';
      case 'recipesortOption.dateadded':
      case 'dateadded':
        return 'date_added';
      case 'recipesortOption.dateupdated':
      case 'dateupdated':
        return 'date_updated';
      case 'recipesortOption.rating':
      case 'rating':
        return 'rating';
      case 'recipesortOption.cooktime':
      case 'cooktime':
        return 'cook_time';
      default:
        print('DEBUG: Unknown sort option: $sortBy (string: $sortString), using default');
        return 'date_updated';
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _error = error;
  }

  /// Convert RecipeSummary from API to RecipeEntity for UI
  RecipeEntity _convertToEntity(RecipeSummary summary) {
    final imageUrl = _buildImageUrl(summary.image, summary.id);
    return RecipeEntity(
      id: summary.id,
      name: summary.name,
      slug: summary.slug,
      description: summary.description,
      imageUrl: imageUrl,
      categories: summary.recipeCategory
              ?.map((cat) => RecipeCategoryEntity(
                    id: cat.id,
                    name: cat.name,
                    slug: cat.slug,
                  ))
              .toList() ??
          [],
      tags: summary.tags
              ?.map((tag) => RecipeTagEntity(
                    id: tag.id,
                    name: tag.name,
                    slug: tag.slug,
                  ))
              .toList() ??
          [],
      rating: summary.rating,
      dateAdded: summary.dateAdded,
      dateUpdated: summary.dateUpdated,
      // Set defaults for fields not available in RecipeSummary
      ingredients: const [],
      instructions: const [],
      settings: const RecipeSettingsEntity(),
      assets: const [],
      notes: const [],
      isFavorite: false, // Would need to be fetched separately
      timesMade: 0,
    );
  }

  /// Build full image URL - always try standard Mealie format regardless of API image field
  String _buildImageUrl(String? relativePath, String recipeId) {
    // Build full URL using the Mealie server base URL
    final baseUrl = _mealieClient.baseUrl.endsWith('/')
        ? _mealieClient.baseUrl.substring(0, _mealieClient.baseUrl.length - 1)
        : _mealieClient.baseUrl;

    String fullUrl;

    // If it's already a proper API path, use it
    if (relativePath != null &&
        relativePath.startsWith('/api/media/recipes/')) {
      fullUrl = '$baseUrl$relativePath';
    }
    // If it's already a full URL, return as-is
    else if (relativePath != null && relativePath.startsWith('http')) {
      fullUrl = relativePath;
    }
    // Otherwise, always try the standard Mealie media URL format
    else {
      // Mealie standard image format: /api/media/recipes/{recipe-id}/images/original.webp
      fullUrl = '$baseUrl/api/media/recipes/$recipeId/images/original.webp';
    }

    return fullUrl;
  }
}
