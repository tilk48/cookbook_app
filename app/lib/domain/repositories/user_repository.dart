import 'package:mealie_api/mealie_api.dart';
import '../../core/utils/result.dart';

abstract class UserRepository {
  Future<Result<User>> getCurrentUser();
  
  Future<Result<User>> updateUser({
    String? email,
    String? username,
    String? fullName,
  });

  Future<Result<List<String>>> getFavorites();
  
  Future<Result<void>> addFavorite(String recipeId);
  
  Future<Result<void>> removeFavorite(String recipeId);
  
  Future<Result<void>> uploadAvatar(String imagePath);
}