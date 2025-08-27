import 'package:dio/dio.dart';
import '../models/recipe/recipe_models.dart';
import '../models/common/common_models.dart';
import '../exceptions/mealie_exception.dart';

class RecipesApi {
  final Dio _dio;

  RecipesApi(this._dio);

  /// Get paginated list of recipes
  Future<PaginatedResponse<RecipeSummary>> getRecipes({
    QueryParameters? queryParams,
  }) async {
    try {
      final response = await _dio.get(
        '/api/recipes',
        queryParameters: queryParams?.toQueryMap(),
      );
      return PaginatedResponse.fromJson(
        response.data,
        (json) => RecipeSummary.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Get a specific recipe by slug
  Future<Recipe> getRecipe(String slug) async {
    try {
      final response = await _dio.get('/api/recipes/$slug');
      return Recipe.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Create a new recipe
  Future<Recipe> createRecipe(CreateRecipeRequest request) async {
    try {
      final response = await _dio.post('/api/recipes', data: request.toJson());
      return Recipe.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Update an existing recipe
  Future<Recipe> updateRecipe(String slug, CreateRecipeRequest request) async {
    try {
      final response = await _dio.put('/api/recipes/$slug', data: request.toJson());
      return Recipe.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Delete a recipe
  Future<void> deleteRecipe(String slug) async {
    try {
      await _dio.delete('/api/recipes/$slug');
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Search recipes
  Future<PaginatedResponse<RecipeSummary>> searchRecipes({
    required String query,
    QueryParameters? queryParams,
  }) async {
    try {
      final params = queryParams?.toQueryMap() ?? <String, String>{};
      params['search'] = query;
      
      final response = await _dio.get('/api/recipes', queryParameters: params);
      return PaginatedResponse.fromJson(
        response.data,
        (json) => RecipeSummary.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Get recipe categories
  Future<List<RecipeCategory>> getCategories() async {
    try {
      final response = await _dio.get('/api/organizers/categories', queryParameters: {
        'page': '1',
        'perPage': '-1',
        'orderBy': 'name',
        'orderDirection': 'asc',
      });
      
      // The organizers endpoint returns a paginated response
      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        return (data['items'] as List)
            .map((json) => RecipeCategory.fromJson(json))
            .toList();
      } else {
        // Fallback for direct list response
        return (response.data as List)
            .map((json) => RecipeCategory.fromJson(json))
            .toList();
      }
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Get recipe tags
  Future<List<RecipeTag>> getTags() async {
    try {
      // Try the organizers endpoint first
      final response = await _dio.get('/api/organizers/tags');
      return (response.data as List)
          .map((json) => RecipeTag.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Upload recipe image
  Future<void> uploadRecipeImage(String slug, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });
      
      await _dio.put('/api/recipes/$slug/image', data: formData);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }
}