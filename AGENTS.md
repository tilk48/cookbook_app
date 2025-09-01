# AGENTS.md

## Build/Lint/Test Commands

### Flutter App (`/app` directory)
```bash
# Run in debug mode
flutter run

# Build release APK
flutter build apk --release

# Run all unit tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Run integration tests
flutter test integration_test

# Analyze code (linting)
flutter analyze

# Format code
flutter format lib/
```

### API SDK (`/mealie_api` directory)
```bash
# Regenerate models after schema changes
dart run build_runner build --delete-conflicting-outputs

# Run API tests
dart run test

# Run single API test
dart run test test/models_test.dart
```

### CLI Testing Tool
```bash
# Test authentication
dart lib/test/cli_api_test.dart auth

# Test recipe operations
dart lib/test/cli_api_test.dart recipes

# Test specific recipe details
dart lib/test/cli_api_test.dart recipe-detail
```

## Code Style Guidelines

### Architecture
- **Clean Architecture**: Domain/Data/Presentation layers
- **Provider Pattern**: State management with ChangeNotifier
- **Service Locator**: Dependency injection with get_it
- **Repository Pattern**: Data access abstraction
- **Component-Based UI**: Widgets under 150 lines

### Imports & File Structure
```dart
// Relative imports for same package
import '../domain/entities/recipe.dart';
import '../../data/repositories/recipe_repository.dart';

// External package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

// Group imports: external packages, then local imports
// Separate with blank lines between groups
```

### Naming Conventions
- **Classes**: PascalCase (`RecipeProvider`, `AuthRepository`)
- **Variables/Functions**: camelCase (`currentUser`, `getRecipes()`)
- **Private Members**: `_` prefix (`_currentUser`, `_isLoading`)
- **Constants**: UPPER_SNAKE_CASE (`AppConstants.defaultServerUrl`)
- **Files**: snake_case (`auth_provider.dart`, `recipe_repository.dart`)

### Error Handling
```dart
// Use Result pattern for operations that can fail
Future<Result<User>> login(String email, String password) async {
  try {
    final user = await _authRepository.login(email, password);
    return Result.success(user);
  } catch (e) {
    return Result.failure('Login failed: $e');
  }
}

// Use try/catch for async operations
Future<void> _loadData() async {
  try {
    _isLoading = true;
    notifyListeners();
    final data = await _repository.getData();
    _data = data;
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

### Async/Await Patterns
```dart
// Always use async/await over .then()
Future<void> initialize() async {
  await _loadUserData();
  await _setupProviders();
}

// Handle futures properly
Future<User?> getCurrentUser() async {
  if (_currentUser != null) return _currentUser;
  return await _repository.getUser();
}
```

### Widget Guidelines
- Keep widgets under 150 lines
- Extract complex widgets into focused components
- Use meaningful names (`RecipeHeader`, `IngredientsList`)
- Follow Material Design 3 principles
- Use `const` constructors when possible

### State Management
```dart
class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Expose immutable state
  List<Recipe> get recipes => List.unmodifiable(_recipes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Update state and notify listeners
  Future<void> loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await _repository.getRecipes();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Testing Patterns
```dart
// Use descriptive test names
test('should load recipes successfully', () async {
  // Arrange
  final mockRepo = MockRecipeRepository();
  when(mockRepo.getRecipes()).thenAnswer((_) async => [testRecipe]);

  // Act
  await provider.loadRecipes();

  // Assert
  expect(provider.recipes, [testRecipe]);
  expect(provider.isLoading, false);
  expect(provider.errorMessage, null);
});

// Use golden tests for UI components
testGoldens('RecipeCard displays correctly', (tester) async {
  await pumpWidgetForGolden(tester, RecipeCard(recipe: testRecipe));
  await screenMatchesGolden(tester, 'recipe_card');
});
```

### API Integration
- Use type-safe models with JSON serialization
- Handle authentication with interceptors
- Support both camelCase and snake_case field mapping
- Always test API changes with CLI harness first

### Debugging
- Use debug prints with 'DEBUG:' prefix
- Check provider setup with ChangeNotifierProvider wrappers
- Verify service locator registration
- Test API responses before UI implementation