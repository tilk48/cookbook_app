import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../api/auth_api.dart';
import '../api/recipes_api.dart';
import '../api/users_api.dart';
import '../api/meal_plans_api.dart';
import '../api/shopping_lists_api.dart';

class MealieClient {
  late final Dio _dio;
  late final AuthInterceptor _authInterceptor;
  
  // API Services
  late final AuthApi auth;
  late final RecipesApi recipes;
  late final UsersApi users;
  late final MealPlansApi mealPlans;
  late final ShoppingListsApi shoppingLists;

  MealieClient({
    required String baseUrl,
    String? accessToken,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout ?? const Duration(seconds: 10),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 10),
      sendTimeout: sendTimeout ?? const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _authInterceptor = AuthInterceptor(accessToken: accessToken);
    _dio.interceptors.add(_authInterceptor);
    
    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        // Only log in debug mode
        assert(() {
          print(obj);
          return true;
        }());
      },
    ));

    // Initialize API services
    auth = AuthApi(_dio);
    recipes = RecipesApi(_dio);
    users = UsersApi(_dio);
    mealPlans = MealPlansApi(_dio);
    shoppingLists = ShoppingListsApi(_dio);
  }

  /// Update the access token for authenticated requests
  void setAccessToken(String? token) {
    _authInterceptor.setAccessToken(token);
  }

  /// Get the current access token
  String? get accessToken => _authInterceptor.accessToken;

  /// Update the base URL
  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  /// Get the current base URL
  String get baseUrl => _dio.options.baseUrl;

  /// Get the underlying Dio client for direct API access
  Dio get dio => _dio;

  /// Close the client and clean up resources
  void close() {
    _dio.close();
  }
}