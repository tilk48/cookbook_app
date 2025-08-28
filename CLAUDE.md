# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter cookbook app that integrates with the Mealie Recipe Management System API. The app follows clean architecture principles with a clear separation between domain, data, and presentation layers. The project consists of two main parts:

1. **Flutter App** (`/app`) - The main mobile application
2. **Mealie API SDK** (`/mealie_api`) - Custom-generated Dart SDK for the Mealie API

## Development Commands

### Building and Running
```bash
# Navigate to the app directory
cd /home/til/Development/cookbook_app/app

# Run the app in debug mode
flutter run

# Build release APK
flutter build apk --release

# Run tests
flutter test

# Run integration tests
flutter test integration_test
```

### API SDK Development
```bash
# Navigate to the API SDK directory
cd /home/til/Development/cookbook_app/mealie_api

# Regenerate models after schema changes
dart run build_runner build --delete-conflicting-outputs

# Run API tests
dart run test
```

### CLI Testing Tool
The project includes a CLI test harness for direct API testing:
```bash
cd /home/til/Development/cookbook_app/app
dart lib/test/cli_api_test.dart [command]

# Available commands:
# auth - Test authentication
# recipes - Test recipe listing
# recipe-detail - Test specific recipe details
# tags - Test tag filtering
# categories - Test category filtering
```

## Architecture Overview

### Clean Architecture Structure
- **Domain Layer** (`lib/domain/`) - Business logic, entities, repository interfaces
- **Data Layer** (`lib/data/`) - API clients, local storage, repository implementations
- **Presentation Layer** (`lib/presentation/`) - UI components, providers, pages

### Key Architectural Patterns
- **Provider Pattern** for state management
- **Service Locator Pattern** (`get_it`) for dependency injection
- **Repository Pattern** for data access abstraction
- **Component-Based UI** with widgets kept under 150 lines

### Mealie API Integration
The app uses a custom-generated SDK (`mealie_api` package) that provides:
- Type-safe API models with JSON serialization
- Automatic authentication handling
- Error handling and interceptors
- Support for both camelCase and snake_case field mapping

## Key Components

### Authentication Flow
- Onboarding page for server URL configuration
- Login with email/password using multipart form data
- JWT token management with automatic refresh
- Authenticated image loading with fallback

### Recipe Management
- Recipe list with pull-to-refresh and pagination
- Advanced filtering by tags and categories using tabbed interface
- Recipe detail pages with hero animations
- Interactive ingredients with portion scaling
- Cooking step completion tracking
- Portion adjustment controls

### State Management
- `AuthProvider` - Authentication state and user management
- `RecipeProvider` - Recipe list, filtering, and caching
- `RecipeDetailProvider` - Individual recipe state and interactions

### Refactored Components
Recipe detail functionality is split into focused widgets (all <150 lines):
- `RecipeHeader` - Tags, categories, description
- `RecipeStats` - Timing information as list tiles  
- `ServingAdjustment` - Portion scaling controls
- `IngredientsList` - Ingredient display with scaling
- `InstructionsList` - Interactive cooking steps
- `InstructionsProgress` - Step completion tracking

## Data Models

### API Response Handling
The Mealie API returns data in camelCase format, but the models support both camelCase and snake_case through field mapping in the `Recipe.fromJson()` method. Key mappings:
- `recipeIngredient` → `recipe_ingredient`
- `recipeInstructions` → `recipe_instructions`
- `recipeServings` → `recipe_servings`

### Serving Size Logic
- Original serving size from `recipeServings` field (not `recipeYield`)
- Portion scaling uses integer-based logic (e.g., "6/4 portions")
- All ingredients scale proportionally with serving adjustments

## Development Notes

### Component Guidelines
- Keep all UI files under 150 lines
- Extract complex widgets into focused components
- Use meaningful file names and clear separation of concerns
- Follow Material Design 3 principles

### API Testing
Always test API changes using the CLI harness before UI implementation:
```bash
dart lib/test/cli_api_test.dart recipe-detail
```

### Common Debugging
- Check provider setup with `ChangeNotifierProvider` wrappers
- Verify service locator registration in `service_locator.dart`
- Use debug prints with 'DEBUG:' prefix for API response investigation

## Current Development Status
- ✅ Authentication and user management complete
- ✅ Recipe browsing with filtering complete  
- ✅ Recipe detail with interactive features complete
- ✅ Component refactoring complete
- 🚧 Recipe CRUD operations pending
- 🚧 Meal planning features pending
- 🚧 Shopping list functionality pending