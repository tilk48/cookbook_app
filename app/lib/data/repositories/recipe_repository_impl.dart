import '../../domain/repositories/recipe_repository.dart';
import '../datasources/remote/remote_recipe_datasource.dart';
import '../datasources/local/local_recipe_datasource.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RemoteRecipeDataSource remoteDataSource;
  final LocalRecipeDataSource localDataSource;

  RecipeRepositoryImpl({required this.remoteDataSource, required this.localDataSource});
}