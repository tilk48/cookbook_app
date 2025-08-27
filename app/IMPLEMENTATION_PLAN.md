# Mealie Flutter App - Implementation Plan

## Project Overview
This document serves as the comprehensive implementation plan for the Mealie Recipe Management Flutter application. It provides a structured roadmap for building a modern, native-feeling mobile frontend that integrates with the Mealie API.

## Core Objectives
- **Native Feel**: Utilize Flutter Material Design widgets for authentic native experience
- **Practicality First**: Focus on usability and functionality over excessive visual flair  
- **Modern UX**: Clean, intuitive interface following Material Design guidelines
- **Full Integration**: Complete integration with Mealie API functionality

## Architecture Overview

### Technology Stack
- **Frontend**: Flutter (Dart)
- **State Management**: Provider/Riverpod (TBD based on complexity)
- **HTTP Client**: Dio with interceptors for auth
- **Local Storage**: SQLite (sqflite) + SharedPreferences
- **Code Generation**: OpenAPI Generator for Dart SDK
- **Testing**: Flutter Test + Integration Tests

### Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── storage/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── providers/
│   └── themes/
└── main.dart
```

## Implementation Phases

### Phase 1: Foundation Setup ✅ COMPLETED
**Duration**: 1-2 weeks

#### 1.1 SDK Generation & API Integration ✅
- [x] Generate Dart SDK from OpenAPI specification using openapi-generator
- [x] Setup HTTP client with authentication interceptors
- [x] Create base repository pattern for API calls
- [x] Implement error handling and response parsing

**Completion Notes:**
- Created comprehensive Dart SDK in `/mealie_api/` with full type safety
- Implemented `MealieClient` with Dio HTTP client and JWT auth interceptors
- All API services created: Auth, Recipes, Users, MealPlans, ShoppingLists
- Custom `MealieException` with detailed error handling
- 25 Dart files total with 6 generated `.g.dart` files for JSON serialization
- All tests passing (10/10) with comprehensive model coverage

#### 1.2 Project Architecture 🔄 IN PROGRESS
- [ ] Setup Clean Architecture folder structure
- [ ] Configure dependency injection (GetIt)
- [ ] Setup state management solution
- [ ] Configure routing (GoRouter)
- [ ] Setup local database schema (SQLite)

#### 1.3 Authentication System ✅
- [x] Login/logout screens with Material Design
- [x] Token storage and refresh logic
- [x] Authentication state management  
- [x] Onboarding flow for server connection setup
- [x] Remember me functionality

**Completion Notes:**
- Complete authentication flow with JWT token management
- AuthProvider with full state management
- Secure token storage with SharedPreferences
- Login/logout use cases with repository pattern
- Navigation protection based on auth state

### Phase 2: Core Recipe Management 🔄 IN PROGRESS
**Duration**: 2-3 weeks

#### 2.1 Data Models & Storage ✅ COMPLETED
- [x] Recipe entity with all Mealie fields
- [x] User profile models  
- [x] Ingredient and nutrition models
- [ ] Local caching implementation (DEFERRED to Phase 4)
- [ ] Offline-first data synchronization (DEFERRED to Phase 4)

#### 2.2 Recipe List & Search 🔄 IN PROGRESS
- [ ] Recipe grid/list view with Material cards
- [ ] Pull-to-refresh functionality
- [ ] Infinite scroll pagination
- [ ] Search bar with autocomplete
- [ ] Advanced filtering (tags, categories, cook time)
- [ ] Sorting options (name, date, rating)

#### 2.3 Recipe Detail View
- [ ] Full recipe display with hero animations
- [ ] Ingredient list with checkboxes
- [ ] Step-by-step instructions
- [ ] Recipe rating and favorites
- [ ] Share recipe functionality
- [ ] Scale recipe portions

#### 2.4 Recipe CRUD Operations
- [ ] Create new recipe form (multi-step)
- [ ] Photo capture/selection for recipes
- [ ] Edit existing recipes
- [ ] Delete recipes with confirmation
- [ ] Import recipes from URL
- [ ] Export recipes

### Phase 3: Advanced Features
**Duration**: 2-3 weeks

#### 3.1 Meal Planning
- [ ] Weekly/monthly calendar view
- [ ] Drag & drop meal assignment
- [ ] Meal plan templates
- [ ] Auto-generate meal plans
- [ ] Meal plan sharing

#### 3.2 Shopping Lists
- [ ] Auto-generate from meal plans
- [ ] Manual item addition/removal
- [ ] Check off items while shopping
- [ ] Multiple shopping lists
- [ ] Share shopping lists

#### 3.3 User Profile & Settings
- [ ] Profile management screen
- [ ] Dietary preferences and restrictions
- [ ] Unit conversion preferences
- [ ] Dark/light theme toggle
- [ ] Notification settings
- [ ] Data backup/restore

### Phase 4: Polish & Optimization
**Duration**: 1-2 weeks

#### 4.1 Performance & UX
- [ ] Image caching and optimization
- [ ] Loading states and skeletons
- [ ] Error states with retry options
- [ ] Offline mode indicators
- [ ] Smooth animations and transitions

#### 4.2 Testing & Quality
- [ ] Unit tests for business logic
- [ ] Widget tests for UI components
- [ ] Integration tests for user flows
- [ ] Performance testing
- [ ] Accessibility improvements

## Detailed Feature Requirements

### Authentication Features
- OAuth integration (if supported by Mealie)
- JWT token management with refresh
- Biometric login (fingerprint/face)
- Multi-instance support (multiple Mealie servers)

### Recipe Management Features
- Full-text search across recipes
- Recipe categories and tags
- Recipe difficulty and prep time
- Nutritional information display
- Recipe notes and modifications
- Recipe history and versions
- Bulk operations (delete, export)

### Meal Planning Features
- Calendar integration
- Meal type categorization (breakfast, lunch, dinner)
- Leftover tracking
- Meal plan statistics
- Recipe suggestions based on preferences

### Shopping List Features
- Category-based organization
- Price tracking (if supported)
- Store-specific lists
- Barcode scanning (future enhancement)
- Quantity and unit management

### Offline Support Features
- Recipe caching for offline viewing
- Offline recipe creation/editing
- Sync conflict resolution
- Background sync when online
- Data compression for storage efficiency

## API Integration Details

### Core Endpoints to Integrate
```
Authentication:
- POST /api/auth/token (login)
- POST /api/auth/refresh (token refresh)
- POST /api/auth/logout

Recipes:
- GET /api/recipes (list with pagination/filtering)
- GET /api/recipes/{slug} (recipe details)
- POST /api/recipes (create recipe)
- PUT /api/recipes/{slug} (update recipe)
- DELETE /api/recipes/{slug} (delete recipe)

Users:
- GET /api/users/self (user profile)
- PUT /api/users/self (update profile)
- GET /api/users/self/favorites (user favorites)
- POST /api/users/self/favorites (add favorite)

Meal Plans:
- GET /api/households/mealplans (list meal plans)
- POST /api/households/mealplans (create meal plan)
- PUT /api/households/mealplans/{id} (update meal plan)

Shopping Lists:
- GET /api/households/shopping/lists (get shopping lists)
- POST /api/households/shopping/lists (create list)
- PUT /api/households/shopping/lists/{id} (update list)
```

## UI/UX Guidelines

### Material Design Components to Use
- **AppBar**: Standard app bars with search functionality
- **Cards**: Recipe cards with elevation and rounded corners
- **FAB**: Floating action button for primary actions (add recipe)
- **BottomNavigationBar**: Main navigation between sections
- **Tabs**: Secondary navigation within sections
- **Lists**: ListTile for settings and simple lists
- **Dialogs**: Modal dialogs for confirmations and forms
- **SnackBars**: Feedback and undo actions
- **Chips**: Tags and filter selections

### Color Scheme & Theming
- Use Material Design 3 color system
- Support both light and dark themes
- Primary color: Cooking/food-inspired (warm orange/red)
- Accent colors for categories and status indicators
- High contrast ratios for accessibility

### Navigation Pattern
- Bottom navigation for main sections: Recipes, Meal Plans, Shopping Lists, Profile
- Stack navigation within each section
- Search accessible from app bar
- FAB for primary creation actions
- Consistent back button behavior

## Testing Strategy

### Unit Testing
- Repository pattern testing
- Business logic validation
- State management testing
- Utility function testing

### Widget Testing
- Screen rendering tests
- User interaction testing
- Navigation flow testing
- Form validation testing

### Integration Testing
- End-to-end user flows
- API integration testing
- Offline/online sync testing
- Performance benchmarking

## Development Milestones

### Milestone 1: Authentication & Basic Setup (Week 1-2)
- SDK generation complete
- Authentication flow working
- Basic app structure in place
- API connectivity established

### Milestone 2: Recipe Core Features (Week 3-5)
- Recipe listing and search functional
- Recipe detail view complete
- Basic CRUD operations working
- Image handling implemented

### Milestone 3: Advanced Features (Week 6-8)
- Meal planning functionality
- Shopping lists implemented
- Offline support working
- User preferences setup

### Milestone 4: Polish & Release (Week 9-10)
- All tests passing
- Performance optimized
- Accessibility compliance
- Ready for app store submission

## Dependencies to Add

```yaml
dependencies:
  # State Management
  provider: ^6.1.2
  
  # Network & API
  dio: ^5.4.2+1
  retrofit: ^4.1.0
  json_annotation: ^4.8.1
  
  # Local Storage
  sqflite: ^2.3.3+1
  shared_preferences: ^2.2.2
  
  # Navigation
  go_router: ^13.2.4
  
  # Dependency Injection
  get_it: ^7.6.7
  
  # Image Handling
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  
  # Utilities
  intl: ^0.19.0
  uuid: ^4.3.3

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.9
  json_serializable: ^6.7.1
  retrofit_generator: ^8.1.0
  
  # Testing
  mockito: ^5.4.4
  integration_test:
    sdk: flutter
```

## Success Criteria

### Functional Requirements
- [ ] User can authenticate with Mealie server
- [ ] User can view and search recipe collection
- [ ] User can create, edit, and delete recipes
- [ ] User can plan meals on a calendar
- [ ] User can generate and manage shopping lists
- [ ] App works offline with data sync

### Performance Requirements
- [ ] App startup time < 3 seconds
- [ ] Recipe list loads within 2 seconds
- [ ] Smooth 60fps animations
- [ ] < 100MB storage for cached data
- [ ] Works on devices with 2GB+ RAM

### Quality Requirements
- [ ] 90%+ test coverage
- [ ] Zero crash rate in testing
- [ ] WCAG AA accessibility compliance
- [ ] Support for Android 7+ and iOS 12+
- [ ] Clean Architecture principles followed

## Next Steps

1. **Immediate**: Generate Dart SDK from OpenAPI specification
2. **Week 1**: Setup project structure and authentication
3. **Week 2**: Implement basic recipe listing and viewing
4. **Week 3-4**: Build recipe CRUD functionality
5. **Week 5-6**: Add meal planning and shopping lists
6. **Week 7-8**: Implement offline support and polish
7. **Week 9-10**: Testing, optimization, and release preparation

This plan provides a comprehensive roadmap for implementing a full-featured Mealie Flutter application while maintaining focus on practicality and native Material Design experience.