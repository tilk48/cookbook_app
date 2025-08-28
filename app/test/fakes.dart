import 'package:cookbook_app/core/utils/result.dart';
import 'package:cookbook_app/domain/repositories/auth_repository.dart';
import 'package:mealie_api/mealie_api.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Result<TokenResponse>> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    return ResultFailure<TokenResponse>('no-op');
  }

  @override
  Future<Result<void>> logout() async {
    return const Success(null);
  }

  @override
  Future<Result<TokenResponse>> refreshToken() async {
    return ResultFailure<TokenResponse>('no-op');
  }

  @override
  Future<Result<void>> register({
    required String email,
    required String username,
    required String fullName,
    required String password,
    required String passwordConfirm,
  }) async {
    return const Success(null);
  }
}
