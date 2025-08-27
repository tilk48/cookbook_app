import 'package:mealie_api/mealie_api.dart';
import '../../../core/utils/result.dart';
import '../../repositories/auth_repository.dart';
import '../../../presentation/providers/auth_provider.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Result<TokenResponse>> call(LoginParams params) async {
    return await _repository.login(
      username: params.username,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}