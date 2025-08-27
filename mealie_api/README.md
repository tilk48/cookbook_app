# Mealie API Dart SDK

A comprehensive Dart SDK for interacting with the Mealie Recipe Management System API.

## Features

- **Full API Coverage**: Authentication, Recipes, Users, Meal Plans, Shopping Lists
- **Type Safety**: Strongly typed models with JSON serialization
- **Error Handling**: Comprehensive error handling with custom exceptions  
- **Authentication**: JWT token management with automatic header injection
- **Pagination**: Built-in pagination support
- **File Uploads**: Support for image and file uploads
- **Logging**: Request/response logging for debugging

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  mealie_api:
    path: ../mealie_api
```

## Quick Start

```dart
import 'package:mealie_api/mealie_api.dart';

// Initialize the client
final client = MealieClient(
  baseUrl: 'https://your-mealie-server.com',
);

// Login
final loginRequest = LoginRequest(
  username: 'your_username',
  password: 'your_password',
);

try {
  final tokenResponse = await client.auth.login(loginRequest);
  client.setAccessToken(tokenResponse.accessToken);
  
  // Now you can make authenticated requests
  final user = await client.users.getCurrentUser();
  print('Logged in as: ${user.fullName}');
  
} catch (MealieException e) {
  print('Login failed: ${e.message}');
}
```

## API Usage

### Recipes

```dart
// Get recipes with pagination
final recipes = await client.recipes.getRecipes(
  queryParams: QueryParameters(
    page: 1,
    perPage: 20,
    search: 'pasta',
    orderBy: 'name',
    orderDirection: OrderDirection.asc,
  ),
);

// Get a specific recipe
final recipe = await client.recipes.getRecipe('recipe-slug');

// Create a new recipe
final newRecipe = await client.recipes.createRecipe(
  CreateRecipeRequest(
    name: 'My New Recipe',
    description: 'A delicious recipe',
    recipeIngredient: [
      RecipeIngredient(
        food: 'Flour',
        quantity: 2.0,
        unit: 'cups',
      ),
    ],
    recipeInstructions: [
      CreateRecipeInstruction(
        title: 'Step 1',
        text: 'Mix ingredients together',
      ),
    ],
  ),
);

// Upload recipe image
await client.recipes.uploadRecipeImage('recipe-slug', '/path/to/image.jpg');
```

### Meal Plans

```dart
// Get today's meal plan
final todaysPlan = await client.mealPlans.getTodaysMealPlan();

// Create a meal plan entry
final entry = await client.mealPlans.createPlanEntry(
  CreatePlanEntryRequest(
    date: DateTime.now(),
    entryType: PlanEntryType.dinner,
    title: 'Spaghetti Carbonara',
    recipeId: 'recipe-id',
  ),
);
```

### Shopping Lists

```dart
// Get all shopping lists
final lists = await client.shoppingLists.getShoppingLists();

// Create a new shopping list
final newList = await client.shoppingLists.createShoppingList(
  CreateShoppingListRequest(name: 'Weekly Groceries'),
);

// Add item to list
await client.shoppingLists.addItemToList(
  listId,
  CreateShoppingListItemRequest(
    note: 'Organic Apples',
    quantity: 6.0,
    unit: 'pieces',
  ),
);
```

### Error Handling

```dart
try {
  final recipe = await client.recipes.getRecipe('non-existent');
} on MealieException catch (e) {
  if (e.isNotFound) {
    print('Recipe not found');
  } else if (e.isUnauthorized) {
    print('Please login first');
  } else if (e.isNetworkError) {
    print('Network connection issue');
  } else {
    print('Error: ${e.message}');
  }
}
```

## Configuration

### Client Configuration

```dart
final client = MealieClient(
  baseUrl: 'https://your-mealie-server.com',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 30),
  sendTimeout: Duration(seconds: 30),
);
```

### Authentication

The SDK automatically manages JWT tokens. After login, all requests will include the Bearer token in the Authorization header.

```dart
// Login and store token
final token = await client.auth.login(loginRequest);
client.setAccessToken(token.accessToken);

// Token is now used for all subsequent requests
final user = await client.users.getCurrentUser();

// Clear token on logout
await client.auth.logout();
client.setAccessToken(null);
```

## Models

All API responses are typed using generated models:

- `Recipe` / `RecipeSummary` - Recipe data
- `User` - User profile information  
- `MealPlan` / `PlanEntry` - Meal planning data
- `ShoppingList` / `ShoppingListItem` - Shopping list data
- `PaginatedResponse<T>` - Paginated API responses
- `TokenResponse` - Authentication tokens

## Development

### Code Generation

This SDK uses code generation for JSON serialization. After modifying model classes, run:

```bash
flutter packages pub run build_runner build
```

### Testing

Run tests with:

```bash
flutter test
```

## License

This SDK is open source and available under the MIT License.