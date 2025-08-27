# Changelog

All notable changes to the Mealie API Dart SDK will be documented in this file.

## [1.0.0] - 2024-01-01

### Added
- Initial release of Mealie API Dart SDK
- Complete authentication system with JWT token management
- Full recipe management API (CRUD operations, search, categories, tags)
- User management API (profile, favorites, avatar upload)
- Meal planning API (create, update, delete meal plans)
- Shopping lists API (create, manage lists and items)
- Comprehensive error handling with `MealieException`
- Type-safe models with JSON serialization
- Pagination support with `PaginatedResponse<T>`
- File upload support for images
- Request/response logging for debugging
- Complete test coverage for all models
- Comprehensive documentation and examples

### Features
- **Authentication**: Login, logout, token refresh, user registration
- **Recipes**: Full CRUD, search, filtering, categories, tags, image upload
- **Users**: Profile management, favorites, avatar upload
- **Meal Plans**: Calendar-based meal planning
- **Shopping Lists**: Create and manage shopping lists with items
- **Error Handling**: Detailed error information with network error detection
- **Type Safety**: Strongly typed models for all API responses
- **Pagination**: Built-in pagination with metadata
- **File Uploads**: Support for recipe images and user avatars

### Technical Details
- Built with Dio HTTP client
- JSON serialization with code generation
- Clean architecture with separation of concerns
- Comprehensive test coverage
- Flutter/Dart best practices