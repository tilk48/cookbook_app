/// Mealie API Dart SDK
library mealie_api;

// Core API client
export 'src/client/mealie_client.dart';
export 'src/client/auth_interceptor.dart';

// API Services
export 'src/api/auth_api.dart';
export 'src/api/recipes_api.dart';
export 'src/api/users_api.dart';
export 'src/api/meal_plans_api.dart';
export 'src/api/shopping_lists_api.dart';

// Models
export 'src/models/auth/auth_models.dart';
export 'src/models/recipe/recipe_models.dart';
export 'src/models/user/user_models.dart';
export 'src/models/meal_plan/meal_plan_models.dart';
export 'src/models/shopping_list/shopping_list_models.dart';
export 'src/models/common/common_models.dart';

// Exceptions
export 'src/exceptions/mealie_exception.dart';

// Utils
export 'src/utils/date_utils.dart';