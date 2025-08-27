import 'package:mealie_api/mealie_api.dart';
import '../../core/utils/result.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/remote_user_datasource.dart';
import '../datasources/local/local_user_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final RemoteUserDataSource _remoteDataSource;
  final LocalUserDataSource _localDataSource;

  UserRepositoryImpl({
    required RemoteUserDataSource remoteDataSource,
    required LocalUserDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Failed to get current user').toFailure();
    }
  }

  @override
  Future<Result<User>> updateUser({
    String? email,
    String? username,
    String? fullName,
  }) async {
    try {
      return await _remoteDataSource.updateUser(
        email: email,
        username: username,
        fullName: fullName,
      );
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Failed to update user').toFailure();
    }
  }

  @override
  Future<Result<List<String>>> getFavorites() async {
    try {
      return await _remoteDataSource.getFavorites();
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Failed to get favorites').toFailure();
    }
  }

  @override
  Future<Result<void>> addFavorite(String recipeId) async {
    try {
      return await _remoteDataSource.addFavorite(recipeId);
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Failed to add favorite').toFailure();
    }
  }

  @override
  Future<Result<void>> removeFavorite(String recipeId) async {
    try {
      return await _remoteDataSource.removeFavorite(recipeId);
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Failed to remove favorite').toFailure();
    }
  }

  @override
  Future<Result<void>> uploadAvatar(String imagePath) async {
    try {
      return await _remoteDataSource.uploadAvatar(imagePath);
    } on MealieException catch (e) {
      return _handleMealieException(e).toFailure();
    } catch (e) {
      return const ServerFailure(message: 'Failed to upload avatar').toFailure();
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