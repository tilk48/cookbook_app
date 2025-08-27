import 'package:flutter/foundation.dart';
import 'package:mealie_api/mealie_api.dart';

import '../../core/storage/auth_storage.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../core/utils/result.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase? _getCurrentUserUseCase;
  final AuthStorage _authStorage;
  final MealieClient _mealieClient;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    GetCurrentUserUseCase? getCurrentUserUseCase,
    required AuthStorage authStorage,
    required MealieClient mealieClient,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _authStorage = authStorage,
        _mealieClient = mealieClient {
    _initializeAuth();
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _authStorage.isLoggedIn() && (_getCurrentUserUseCase == null || _currentUser != null);
  bool get hasServerUrl => _authStorage.getServerUrl() != null;
  String? get serverUrl => _authStorage.getServerUrl();
  String? get accessToken => _authStorage.getAccessToken();

  Future<void> _initializeAuth() async {
    if (_authStorage.isLoggedIn()) {
      final token = _authStorage.getAccessToken();
      if (token != null) {
        _mealieClient.setAccessToken(token);
        await _loadCurrentUser();
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    if (_getCurrentUserUseCase != null) {
      final result = await _getCurrentUserUseCase!();
      
      result.onSuccess((user) {
        _currentUser = user;
        notifyListeners();
      }).onFailure((failure) {
        // If user loading fails, likely token expired
        _clearUserData();
      });
    }
  }

  Future<Result<void>> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _loginUseCase(LoginParams(
      username: username,
      password: password,
      rememberMe: rememberMe,
    ));

    if (result.isSuccess) {
      final tokenResponse = result.value;
      // Update client with new token
      _mealieClient.setAccessToken(tokenResponse.accessToken);
      
      // Load user profile
      if (_getCurrentUserUseCase != null) {
        final userResult = await _getCurrentUserUseCase!();
        
        if (userResult.isSuccess) {
          _currentUser = userResult.value;
          _authStorage.setLoggedIn(true);
          _authStorage.setRememberMe(rememberMe);
          _setLoading(false);
          notifyListeners();
          return const Success(null);
        } else {
          _setError('Failed to load user profile');
          _setLoading(false);
          return userResult.failure.toFailure();
        }
      } else {
        // No user use case available, just mark as logged in
        _authStorage.setLoggedIn(true);
        _authStorage.setRememberMe(rememberMe);
        _setLoading(false);
        notifyListeners();
        return const Success(null);
      }
    } else {
      _setError(result.failure?.message ?? 'Login failed');
      _setLoading(false);
      return result.failure.toFailure();
    }
  }

  Future<Result<void>> logout() async {
    _setLoading(true);
    _clearError();

    final result = await _logoutUseCase();
    
    result.onSuccess((_) {
      _clearUserData();
    }).onFailure((failure) {
      // Even if logout fails on server, clear local data
      _clearUserData();
    });

    return result;
  }

  Future<void> setServerUrl(String url) async {
    await _authStorage.setServerUrl(url);
    _mealieClient.setBaseUrl(url);
    notifyListeners();
  }

  void _clearUserData() {
    _currentUser = null;
    _mealieClient.setAccessToken(null);
    _authStorage.clearAll();
    _setLoading(false);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();

  /// Load current user data from server
  Future<void> loadCurrentUser() async {
    if (!isLoggedIn) return;
    
    try {
      _setLoading(true);
      final user = await _mealieClient.users.getCurrentUser();
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load user profile: ${e.toString()}');
      _setLoading(false);
    }
  }
}

class LoginParams {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginParams({
    required this.username,
    required this.password,
    this.rememberMe = false,
  });
}