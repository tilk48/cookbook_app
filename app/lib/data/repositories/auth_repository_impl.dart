import 'package:mealie_api/mealie_api.dart';
import '../../core/utils/result.dart';
import '../../core/error/failures.dart';
import '../../core/storage/auth_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/remote_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource _remoteDataSource;
  final AuthStorage _authStorage;

  AuthRepositoryImpl({
    required RemoteAuthDataSource remoteDataSource,
    required AuthStorage authStorage,
  })  : _remoteDataSource = remoteDataSource,
        _authStorage = authStorage;

  @override
  Future<Result<TokenResponse>> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final result = await _remoteDataSource.login(
        username: username,
        password: password,
        rememberMe: rememberMe,
      );

      if (result.isSuccess) {
        final tokenResponse = result.value;
        // Store tokens locally
        await _authStorage.setAccessToken(tokenResponse.accessToken);
        // Note: Mealie might not provide refresh token in all cases
        // await _authStorage.setRefreshToken(tokenResponse.refreshToken ?? '');
        
        return tokenResponse.toSuccess();
      } else {
        return result;
      }
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Login failed').toFailure();
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final result = await _remoteDataSource.logout();
      
      if (result.isSuccess) {
        await _authStorage.clearAll();
        return const Success(null);
      } else {
        await _authStorage.clearAll();
        return result;
      }
    } on MealieException catch (e) {
      // Clear local data even if remote logout fails
      await _authStorage.clearAll();
      return _handleMealieException(e).toFailure();
    } catch (e) {
      await _authStorage.clearAll();
      return const ServerFailure(message: 'Logout failed').toFailure();
    }
  }

  @override
  Future<Result<TokenResponse>> refreshToken() async {
    try {
      final refreshToken = _authStorage.getRefreshToken();
      if (refreshToken == null) {
        return const AuthFailure(message: 'No refresh token available').toFailure();
      }

      final result = await _remoteDataSource.refreshToken(refreshToken);
      
      if (result.isSuccess) {
        final tokenResponse = result.value;
        await _authStorage.setAccessToken(tokenResponse.accessToken);
        return tokenResponse.toSuccess();
      } else {
        return result;
      }
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const AuthFailure(message: 'Token refresh failed').toFailure();
    }
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      return await _remoteDataSource.register(
        email: email,
        username: username,
        fullName: fullName,
        password: password,
        passwordConfirm: passwordConfirm,
      );
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Registration failed').toFailure();
    }
  }

  Failure _handleMealieException(MealieException e) {
    if (e.isUnauthorized) {
      return AuthFailure(message: e.message, code: e.statusCode);
    } else if (e.isNetworkError) {
      return NetworkFailure(message: e.message, code: e.statusCode);
    } else if (e.isServerError) {
      return ServerFailure(message: e.message, code: e.statusCode);
    } else if (e.isNotFound) {
      return NotFoundFailure(message: e.message, code: e.statusCode);
    } else {
      return ServerFailure(message: e.message, code: e.statusCode);
    }
  }
}