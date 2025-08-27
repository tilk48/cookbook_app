# Cookbook App - System Design Documentation

This document captures the major architectural and design decisions made during the development of the Mealie Flutter frontend application. It serves as a reference for future development and onboarding of new developers.

## Overview

The Cookbook app is a Flutter-based mobile frontend for the Mealie Recipe Management System. It follows Clean Architecture principles with a focus on maintainability, testability, and native Material Design experience.

## Core Architectural Decisions

### 1. Clean Architecture Implementation

**Decision**: Implemented Robert C. Martin's Clean Architecture with clear separation of concerns.

**Structure**:
```
lib/
├── core/           # Shared utilities, constants, and cross-cutting concerns
├── data/           # Data layer - API calls, local storage, repositories
├── domain/         # Business logic - entities, use cases, repository interfaces
├── presentation/   # UI layer - pages, widgets, state management
```

**Reasoning**:
- **Separation of Concerns**: Each layer has a single responsibility
- **Testability**: Business logic isolated from UI and external dependencies
- **Maintainability**: Changes in one layer don't cascade to others
- **Scalability**: Easy to add new features without architectural changes
- **Team Development**: Multiple developers can work on different layers simultaneously

### 2. State Management - Provider Pattern

**Decision**: Used Provider for state management instead of BLoC, Riverpod, or setState.

**Implementation**:
- `AuthProvider` for authentication state
- Individual providers for each feature domain
- Dependency injection through service locator

**Reasoning**:
- **Simplicity**: Provider is straightforward and well-documented
- **Flutter Integration**: Official Flutter recommendation for state management
- **Performance**: Selective rebuilds only when necessary
- **Learning Curve**: Easier for developers familiar with Flutter
- **Future Migration**: Can be easily migrated to Riverpod if needed

### 3. Dependency Injection - GetIt Service Locator

**Decision**: Used GetIt service locator pattern instead of constructor injection or manual dependency management.

**Implementation**:
- Central `ServiceLocator` class managing all dependencies
- Lazy initialization for performance
- Clear separation between singletons and factory instances

**Reasoning**:
- **Decoupling**: Reduces tight coupling between classes
- **Testing**: Easy to mock dependencies for unit tests
- **Configuration**: Single place to configure all dependencies
- **Performance**: Lazy loading reduces startup time
- **Simplicity**: More straightforward than complex DI frameworks

### 4. Navigation - GoRouter

**Decision**: Chose GoRouter over Navigator 2.0 or auto_route.

**Features Implemented**:
- Declarative routing configuration
- Route protection based on authentication state
- Deep linking support
- Type-safe navigation with extensions

**Reasoning**:
- **Official Support**: Maintained by Flutter team
- **Declarative**: Routes defined in single place
- **Authentication Integration**: Built-in redirect functionality
- **Deep Linking**: Excellent web and mobile deep link support
- **Type Safety**: Route parameters are type-safe

### 5. Error Handling - Result Pattern

**Decision**: Implemented custom Result<T> type instead of throwing exceptions.

**Implementation**:
- `Result<T>` sealed class with `Success<T>` and `ResultFailure<T>`
- Monadic operations: `map`, `flatMap`, `onSuccess`, `onFailure`
- Extension methods for easy creation

**Reasoning**:
- **Explicit Error Handling**: Forces developers to handle errors
- **No Silent Failures**: All error paths must be explicitly handled
- **Functional Programming**: Enables clean, composable error handling
- **Type Safety**: Compiler ensures all cases are handled
- **Performance**: No exception throwing overhead

### 6. Local Storage - SQLite + SharedPreferences Hybrid

**Decision**: Used SQLite for complex relational data and SharedPreferences for simple key-value storage.

**Data Storage Strategy**:
- **SQLite**: Recipes, ingredients, meal plans, shopping lists (structured data)
- **SharedPreferences**: Authentication tokens, user preferences (simple data)

**Reasoning**:
- **Performance**: SQLite optimized for complex queries and relationships
- **Simplicity**: SharedPreferences perfect for simple key-value pairs
- **Offline Support**: SQLite enables robust offline functionality
- **Data Integrity**: Foreign keys and constraints ensure data consistency
- **Flexibility**: Can handle both simple and complex data requirements

### 7. API Integration - Generated SDK + Repository Pattern

**Decision**: Generated Dart SDK from OpenAPI specification combined with Repository pattern.

**Architecture**:
- Generated `MealieClient` with all API endpoints
- Repository interfaces in domain layer
- Repository implementations in data layer wrapping SDK calls

**Reasoning**:
- **Type Safety**: Generated code ensures API contract compliance
- **Maintainability**: API changes automatically reflected in code
- **Abstraction**: Repository pattern abstracts API details from business logic
- **Testing**: Easy to mock repository interfaces
- **Consistency**: Consistent error handling across all API calls

### 8. Offline-First Design

**Decision**: Designed the app to work offline-first with background synchronization.

**Implementation Strategy**:
- Local SQLite database as primary data store
- Background sync when network available
- Conflict resolution for concurrent modifications
- Cache invalidation strategies

**Reasoning**:
- **User Experience**: App remains functional without internet
- **Performance**: Local data access is faster than network calls
- **Reliability**: Reduces dependency on network connectivity
- **Mobile Optimization**: Conserves battery and data usage

### 9. Material Design 3 with Custom Theme

**Decision**: Built custom theme based on Material Design 3 principles with food/cooking color palette.

**Theme Strategy**:
- Warm color palette (reds, oranges) reflecting cooking/food theme
- Full light/dark mode support
- Consistent spacing using predefined constants
- Native Flutter widgets prioritized over custom components

**Reasoning**:
- **Native Feel**: Users get familiar, platform-consistent experience
- **Accessibility**: Material Design includes accessibility best practices
- **Maintenance**: Less custom code means fewer bugs and easier updates
- **Performance**: Native widgets are optimized by Flutter team
- **Brand Identity**: Custom colors while maintaining usability

### 10. Testing Strategy - Multi-Layer Approach

**Decision**: Comprehensive testing strategy covering all architectural layers.

**Testing Levels**:
- **Unit Tests**: Use cases, repositories, utilities
- **Widget Tests**: Individual UI components
- **Integration Tests**: End-to-end user flows
- **API Tests**: SDK and repository integration

**Reasoning**:
- **Quality Assurance**: Multiple test levels catch different types of bugs
- **Regression Prevention**: Automated tests prevent breaking changes
- **Documentation**: Tests serve as living documentation of expected behavior
- **Confidence**: Comprehensive tests enable safe refactoring

## Technology Stack Decisions

### Primary Dependencies

1. **Flutter SDK 3.5.1+**: Latest stable version with Material 3 support
2. **Provider 6.1.2**: State management
3. **GoRouter 13.2.4**: Navigation
4. **GetIt 7.6.7**: Dependency injection
5. **Dio 5.4.2**: HTTP client (via Mealie SDK)
6. **SQLite 2.3.3**: Local database
7. **SharedPreferences 2.2.2**: Simple key-value storage

### Development Dependencies

1. **Flutter Test**: Unit and widget testing
2. **Mockito 5.4.4**: Mocking for tests
3. **Integration Test**: End-to-end testing
4. **Flutter Lints 4.0.0**: Code quality and consistency

## Performance Optimizations

### 1. Lazy Loading Strategy
- Service locator uses lazy initialization
- Images loaded on demand with caching
- Database connections pooled and reused

### 2. Memory Management
- Proper disposal of controllers and streams
- Image caching with size limits
- Database query optimization with indexes

### 3. Network Optimization
- Request/response interceptors for caching
- Automatic token refresh to minimize auth failures
- Offline queue for failed requests

## Security Considerations

### 1. Token Storage
- JWT tokens stored securely in SharedPreferences
- Automatic token refresh before expiration
- Tokens cleared on logout or app uninstall

### 2. API Security
- All API calls use HTTPS
- Authentication headers automatically added
- No sensitive data logged in production

### 3. Data Protection
- Local database not encrypted (contains only cached public data)
- User credentials never stored locally
- Server URL validation to prevent malicious redirects

## Scalability Considerations

### 1. Code Organization
- Feature-based folder structure within each layer
- Clear interfaces for easy feature addition
- Minimal coupling between features

### 2. Performance Scaling
- Pagination for large data sets
- Virtual scrolling for long lists
- Background processing for heavy operations

### 3. Team Scaling
- Clear architectural boundaries for parallel development
- Comprehensive documentation and code comments
- Consistent coding patterns and conventions

## Future Migration Paths

### 1. State Management Evolution
- Current Provider can be easily migrated to Riverpod
- State logic is isolated in provider classes
- Minimal UI changes required for migration

### 2. Database Evolution
- SQLite schema includes migration support
- Repository pattern abstracts database implementation
- Can switch to other databases (Hive, Drift) if needed

### 3. Platform Expansion
- Clean Architecture supports web and desktop
- UI layer can be adapted for different screen sizes
- Core business logic remains unchanged

## Development Guidelines

### 1. Adding New Features
1. Define domain entities and use cases
2. Create repository interface in domain layer
3. Implement repository in data layer
4. Create provider for state management
5. Build UI components in presentation layer
6. Add comprehensive tests

### 2. Error Handling Standards
- Always use Result<T> for operations that can fail
- Handle all error cases explicitly
- Provide meaningful error messages to users
- Log errors for debugging but don't expose sensitive information

### 3. Code Quality Standards
- Follow Flutter/Dart linting rules
- Use meaningful variable and function names
- Add documentation for public APIs
- Keep functions small and focused
- Write tests for all business logic

## Conclusion

These design decisions were made to create a maintainable, scalable, and user-friendly recipe management application. The architecture supports rapid feature development while maintaining code quality and performance. The offline-first approach ensures a reliable user experience regardless of network conditions.

The combination of Clean Architecture, modern Flutter practices, and thoughtful technology choices provides a solid foundation for long-term development and maintenance of the Cookbook app.