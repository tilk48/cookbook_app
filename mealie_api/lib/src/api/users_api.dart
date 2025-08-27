import 'package:dio/dio.dart';
import '../models/user/user_models.dart';
import '../exceptions/mealie_exception.dart';

class UsersApi {
  final Dio _dio;

  UsersApi(this._dio);

  /// Get current user profile
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/users/self');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Update current user profile
  Future<User> updateCurrentUser(UpdateUserRequest request) async {
    try {
      final response = await _dio.put('/api/users/self', data: request.toJson());
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Upload user avatar
  Future<void> uploadAvatar(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });
      
      await _dio.put('/api/users/self/image', data: formData);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Get user favorites
  Future<List<String>> getFavorites() async {
    try {
      final response = await _dio.get('/api/users/self/favorites');
      return (response.data as List).cast<String>();
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Add recipe to favorites
  Future<void> addFavorite(String recipeId) async {
    try {
      await _dio.post('/api/users/self/favorites', data: {'id': recipeId});
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Remove recipe from favorites
  Future<void> removeFavorite(String recipeId) async {
    try {
      await _dio.delete('/api/users/self/favorites/$recipeId');
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }
}