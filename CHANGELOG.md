# Changelog

All notable changes to the Cookbook Flutter app will be documented in this file.

## [0.2.0] - 2025-08-27

### Added - Authentication Flow Implementation

#### 🔐 Complete Authentication System
- **Onboarding Page** (`lib/presentation/pages/onboarding/onboarding_page.dart`)
  - Server URL configuration with validation
  - Material Design form with URL input field
  - Interactive examples (localhost, network IP, domain)
  - URL validation with proper scheme and authority checks
  - Loading states and error handling

- **Login Page** (`lib/presentation/pages/auth/login_page.dart`)
  - Modern Material Design login form
  - Username and password fields with validation
  - Password visibility toggle
  - Remember me checkbox
  - Server URL display showing configured endpoint
  - Loading states during authentication
  - Error handling with snackbar notifications
  - Demo data skip option for development

#### 🛣️ Authentication Routing Flow
- **Updated Router** (`lib/core/navigation/app_router.dart`)
  - Comprehensive redirect logic based on auth state
  - Protected routes requiring authentication
  - Proper flow: Splash → Onboarding → Login → Recipes

- **Enhanced Splash Page** (`lib/presentation/pages/onboarding/splash_page.dart`)
  - Intelligent navigation based on user state
  - Checks for server URL configuration
  - Checks for authentication status
  - Routes users to appropriate page

#### 🎨 UI/UX Improvements
- **Material Design 3** components throughout
- **Consistent theming** with primary colors and surface variants
- **Form validation** with proper error messages
- **Loading indicators** for async operations
- **Responsive design** for different screen sizes
- **Accessibility** features with proper labels

#### 🔧 Technical Implementation
- **AuthProvider Integration**
  - Server URL persistence
  - JWT token management
  - Authentication state management
  - Error handling and user feedback

- **Navigation Guards**
  - Automatic redirects based on auth state
  - Protected routes for authenticated users
  - Seamless user experience

### Technical Details

#### Authentication Flow
1. **Splash Screen** (1 second delay)
   - Checks if server URL is configured
   - Checks if user is authenticated
   - Routes to appropriate next page

2. **Onboarding** (if no server URL)
   - Collects and validates Mealie server URL
   - Examples for localhost, network, and domain setups
   - Saves URL to AuthProvider
   - Routes to login page

3. **Login** (if not authenticated)
   - Displays configured server URL
   - Username/password authentication
   - Remember me functionality
   - Error handling for failed attempts
   - Demo data skip option

4. **Main App** (if authenticated)
   - Routes to recipe list page
   - Full app functionality available

#### Files Modified/Created
- `lib/presentation/pages/onboarding/onboarding_page.dart` - New onboarding flow
- `lib/presentation/pages/auth/login_page.dart` - New login page
- `lib/presentation/pages/onboarding/splash_page.dart` - Enhanced with routing logic
- `lib/core/navigation/app_router.dart` - Added authentication routing
- `lib/main.dart` - Provider configuration

### Previous Changes

## [0.1.0] - 2025-08-27

### Added - Recipe Management UI

#### 📱 Recipe List Interface
- **Comprehensive Recipe List** (`lib/presentation/pages/recipes/recipe_list_page.dart`)
  - Material Design 3 card-based layout
  - Grid and list view toggle
  - Search functionality with real-time filtering
  - Category and rating filters
  - Pull-to-refresh functionality
  - Infinite scroll pagination
  - Loading states and shimmer effects
  - Hero image animations

#### 🎯 Mock Data System
- **RecipeProvider** (`lib/presentation/providers/recipe_provider.dart`)
  - 30+ sample recipes with realistic data
  - Categories: Italian, Mexican, Asian, American, etc.
  - Rating system and cooking times
  - Search and filter functionality
  - Pagination support
  - Made use cases optional for development

#### 🏗️ Architecture Setup
- **Clean Architecture** structure with domain/data/presentation layers
- **Provider** state management pattern
- **Service Locator** dependency injection
- **Material Design 3** theming
- **GoRouter** declarative navigation

#### 🛠️ Technical Fixes
- **Web Compatibility**: Disabled SQLite dependencies for web platform
- **Provider Registration**: Fixed provider configuration in main.dart
- **Navigation**: Resolved infinite loading on splash screen
- **Dependencies**: Optimized imports and null safety

#### Files Created/Modified
- Complete project structure with Clean Architecture
- Recipe models and entities
- Mock data generation system
- Material Design theme configuration
- Navigation and routing setup

---

## Development Notes

- **Platform Support**: Currently optimized for web platform
- **API Integration**: Using mock data for UI development
- **Database**: Local SQLite temporarily disabled for web compatibility
- **Authentication**: JWT token-based with Mealie API integration planned