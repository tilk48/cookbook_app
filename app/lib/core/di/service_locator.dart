import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:mealie_api/mealie_api.dart';

import '../storage/database_helper.dart';
import '../storage/auth_storage.dart';
import '../constants/app_constants.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/meal_plan_repository_impl.dart';
import '../../data/repositories/shopping_list_repository_impl.dart';
import '../../data/datasources/local/local_recipe_datasource.dart';
import '../../data/datasources/local/local_user_datasource.dart';
import '../../data/datasources/remote/remote_recipe_datasource.dart';
import '../../data/datasources/remote/remote_user_datasource.dart';
import '../../data/datasources/remote/remote_auth_datasource.dart';
import '../../data/datasources/remote/remote_meal_plan_datasource.dart';
import '../../data/datasources/remote/remote_shopping_list_datasource.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/recipes/get_recipes_usecase.dart';
import '../../domain/usecases/recipes/get_recipe_usecase.dart';
import '../../domain/usecases/recipes/create_recipe_usecase.dart';
import '../../domain/usecases/recipes/search_recipes_usecase.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/recipe_provider.dart';

final GetIt sl = GetIt.instance;

class ServiceLocator {
  static Future<void> init() async {
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(sharedPreferences);

    // Database temporarily disabled for web
    // final database = await DatabaseHelper.instance.database;
    // sl.registerSingleton<Database>(database);

    // Core services
    // sl.registerSingleton<DatabaseHelper>(DatabaseHelper.instance);
    sl.registerSingleton<AuthStorage>(AuthStorageImpl(sharedPreferences));

    // Mealie API Client
    sl.registerLazySingleton<MealieClient>(
      () => MealieClient(
        baseUrl: sl<AuthStorage>().getServerUrl() ?? AppConstants.defaultServerUrl,
      ),
    );

    // Data sources
    _registerDataSources();

    // Repositories  
    _registerRepositories();

    // Use cases
    _registerUseCases();

    // Providers
    _registerProviders();
  }

  static void _registerDataSources() {
    // Remote data sources
    sl.registerLazySingleton<RemoteAuthDataSource>(
      () => RemoteAuthDataSourceImpl(sl<MealieClient>()),
    );
    sl.registerLazySingleton<RemoteRecipeDataSource>(
      () => RemoteRecipeDataSourceImpl(sl<MealieClient>()),
    );
    sl.registerLazySingleton<RemoteUserDataSource>(
      () => RemoteUserDataSourceImpl(sl<MealieClient>()),
    );
    sl.registerLazySingleton<RemoteMealPlanDataSource>(
      () => RemoteMealPlanDataSourceImpl(sl<MealieClient>()),
    );
    sl.registerLazySingleton<RemoteShoppingListDataSource>(
      () => RemoteShoppingListDataSourceImpl(sl<MealieClient>()),
    );

    // Local data sources - temporarily disabled for web
    // sl.registerLazySingleton<LocalRecipeDataSource>(
    //   () => LocalRecipeDataSourceImpl(sl<Database>()),
    // );
    // sl.registerLazySingleton<LocalUserDataSource>(
    //   () => LocalUserDataSourceImpl(sl<Database>()),
    // );
  }

  static void _registerRepositories() {
    sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: sl<RemoteAuthDataSource>(),
        authStorage: sl<AuthStorage>(),
      ),
    );
    // Temporarily disabled - using mock data in providers instead
    // sl.registerLazySingleton<RecipeRepository>(
    //   () => RecipeRepositoryImpl(
    //     remoteDataSource: sl<RemoteRecipeDataSource>(),
    //     localDataSource: sl<LocalRecipeDataSource>(),
    //   ),
    // );
    // sl.registerLazySingleton<UserRepository>(
    //   () => UserRepositoryImpl(
    //     remoteDataSource: sl<RemoteUserDataSource>(),
    //     localDataSource: sl<LocalUserDataSource>(),
    //   ),
    // );
    sl.registerLazySingleton<MealPlanRepository>(
      () => MealPlanRepositoryImpl(
        remoteDataSource: sl<RemoteMealPlanDataSource>(),
      ),
    );
    sl.registerLazySingleton<ShoppingListRepository>(
      () => ShoppingListRepositoryImpl(
        remoteDataSource: sl<RemoteShoppingListDataSource>(),
      ),
    );
  }

  static void _registerUseCases() {
    // Auth use cases
    sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
    sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
    // sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<UserRepository>()));

    // Recipe use cases - temporarily disabled, using mock data in providers
    // sl.registerLazySingleton(() => GetRecipesUseCase(sl<RecipeRepository>()));
    // sl.registerLazySingleton(() => GetRecipeUseCase(sl<RecipeRepository>()));
    // sl.registerLazySingleton(() => CreateRecipeUseCase(sl<RecipeRepository>()));
    // sl.registerLazySingleton(() => SearchRecipesUseCase(sl<RecipeRepository>()));
  }

  static void _registerProviders() {
    sl.registerFactory(() => AuthProvider(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      // getCurrentUserUseCase: sl<GetCurrentUserUseCase>(), // temporarily disabled
      authStorage: sl<AuthStorage>(),
      mealieClient: sl<MealieClient>(),
    ));

    // RecipeProvider using real API data
    sl.registerFactory(() => RecipeProvider(
      mealieClient: sl<MealieClient>(),
    ));
  }
}