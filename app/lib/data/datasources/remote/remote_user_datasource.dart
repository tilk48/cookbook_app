import 'package:mealie_api/mealie_api.dart';
import '../../../core/utils/result.dart';

abstract class RemoteUserDataSource {
  Future<Result<User>> getCurrentUser();
  Future<Result<User>> updateUser({String? email, String? username, String? fullName});
  Future<Result<List<String>>> getFavorites();
  Future<Result<void>> addFavorite(String recipeId);
  Future<Result<void>> removeFavorite(String recipeId);
  Future<Result<void>> uploadAvatar(String imagePath);
}

class RemoteUserDataSourceImpl implements RemoteUserDataSource {
  final MealieClient _client;

  RemoteUserDataSourceImpl(this._client);

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final user = await _client.users.getCurrentUser();
      return Success(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Result<User>> updateUser({String? email, String? username, String? fullName}) async {
    try {
      final request = UpdateUserRequest(email: email, username: username, fullName: fullName);
      final user = await _client.users.updateCurrentUser(request);
      return Success(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Result<List<String>>> getFavorites() async {
    try {
      final favorites = await _client.users.getFavorites();
      return Success(favorites);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Result<void>> addFavorite(String recipeId) async {
    try {
      await _client.users.addFavorite(recipeId);
      return const Success(null);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Result<void>> removeFavorite(String recipeId) async {
    try {
      await _client.users.removeFavorite(recipeId);
      return const Success(null);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Result<void>> uploadAvatar(String imagePath) async {
    try {
      await _client.users.uploadAvatar(imagePath);
      return const Success(null);
    } catch (e) {
      rethrow;
    }
  }
}