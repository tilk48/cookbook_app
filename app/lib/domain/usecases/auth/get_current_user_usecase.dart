import 'package:mealie_api/mealie_api.dart';
import '../../../core/utils/result.dart';
import '../../repositories/user_repository.dart';

class GetCurrentUserUseCase {
  final UserRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Result<User>> call() async {
    return await _repository.getCurrentUser();
  }
}