import 'package:mealie_api/mealie_api.dart';
import '../../../core/utils/result.dart';

abstract class RemoteAuthDataSource {
  Future<Result<TokenResponse>> login({
    required String username,
    required String password,
    bool rememberMe = false,
  });

  Future<Result<void>> logout();

  Future<Result<TokenResponse>> refreshToken(String refreshToken);

  Future<Result<void>> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
    required String passwordConfirm,
  });
}

class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  final MealieClient _client;

  RemoteAuthDataSourceImpl(this._client);

  @override
  Future<Result<TokenResponse>> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final request = LoginRequest(
        username: username,
        password: password,
        rememberMe: rememberMe,
      );

      final tokenResponse = await _client.auth.login(request);
      return Success(tokenResponse);
    } on MealieException catch (e) {
      rethrow; // Let repository handle this
    } catch (e) {
      throw MealieException(message: 'Login failed: ${e.toString()}');
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _client.auth.logout();
      return const Success(null);
    } on MealieException catch (e) {
      rethrow; // Let repository handle this
    } catch (e) {
      throw MealieException(message: 'Logout failed: ${e.toString()}');
    }
  }

  @override
  Future<Result<TokenResponse>> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final tokenResponse = await _client.auth.refreshToken(request);
      return Success(tokenResponse);
    } on MealieException catch (e) {
      rethrow; // Let repository handle this
    } catch (e) {
      throw MealieException(message: 'Token refresh failed: ${e.toString()}');
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
      final registration = UserRegistration(
        email: email,
        username: username,
        fullName: fullName,
        password: password,
        passwordConfirm: passwordConfirm,
      );

      await _client.auth.register(registration);
      return const Success(null);
    } on MealieException catch (e) {
      rethrow; // Let repository handle this
    } catch (e) {
      throw MealieException(message: 'Registration failed: ${e.toString()}');
    }
  }
}