import 'package:mealie_api/mealie_api.dart';
import '../../core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<TokenResponse>> login({
    required String username,
    required String password,
    bool rememberMe = false,
  });

  Future<Result<void>> logout();

  Future<Result<TokenResponse>> refreshToken();

  Future<Result<void>> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
    required String passwordConfirm,
  });
}