import 'package:dio/dio.dart';
import '../models/auth/auth_models.dart';
import '../exceptions/mealie_exception.dart';

class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  /// Login with username and password
  Future<TokenResponse> login(LoginRequest request) async {
    try {
      // Mealie API requires multipart/form-data format for authentication
      final formData = FormData.fromMap({
        'username': request.username,
        'password': request.password,
        'remember_me': request.rememberMe?.toString() ?? 'false',
      });
      
      final response = await _dio.post('/api/auth/token', data: formData);
      return TokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Refresh access token
  Future<TokenResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _dio.post('/api/auth/refresh', data: request.toJson());
      return TokenResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Logout and invalidate token
  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }

  /// Register a new user
  Future<void> register(UserRegistration registration) async {
    try {
      await _dio.post('/api/users/register', data: registration.toJson());
    } on DioException catch (e) {
      throw MealieException.fromDioException(e);
    }
  }
}