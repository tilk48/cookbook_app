// This file creates all the stub implementations needed for compilation

// Remote data sources
export 'data/datasources/remote/remote_recipe_datasource.dart';
export 'data/datasources/remote/remote_meal_plan_datasource.dart';
export 'data/datasources/remote/remote_shopping_list_datasource.dart';

// Repositories
export 'domain/repositories/recipe_repository.dart';
export 'domain/repositories/meal_plan_repository.dart';
export 'domain/repositories/shopping_list_repository.dart';

// Repository implementations  
export 'data/repositories/recipe_repository_impl.dart';
export 'data/repositories/meal_plan_repository_impl.dart';
export 'data/repositories/shopping_list_repository_impl.dart';

// Use cases
export 'domain/usecases/recipes/get_recipes_usecase.dart';
export 'domain/usecases/recipes/get_recipe_usecase.dart';
export 'domain/usecases/recipes/create_recipe_usecase.dart';
export 'domain/usecases/recipes/search_recipes_usecase.dart';

// Providers
export 'presentation/providers/recipe_provider.dart';

// Pages
export 'presentation/pages/onboarding/splash_page.dart';
export 'presentation/pages/onboarding/onboarding_page.dart';
export 'presentation/pages/auth/login_page.dart';
export 'presentation/pages/auth/register_page.dart';
export 'presentation/pages/home/home_page.dart';
export 'presentation/pages/recipes/recipe_list_page.dart';
export 'presentation/pages/recipes/recipe_detail_page.dart';
export 'presentation/pages/recipes/recipe_create_page.dart';
export 'presentation/pages/recipes/recipe_edit_page.dart';
export 'presentation/pages/meal_plans/meal_plans_page.dart';
export 'presentation/pages/shopping_lists/shopping_lists_page.dart';
export 'presentation/pages/profile/profile_page.dart';
export 'presentation/pages/profile/settings_page.dart';