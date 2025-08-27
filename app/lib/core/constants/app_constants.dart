class AppConstants {
  // App Info
  static const String appName = 'Cookbook';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Modern recipe management app powered by Mealie';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String serverUrlKey = 'server_url';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  static const String rememberMeKey = 'remember_me';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Database
  static const String databaseName = 'cookbook.db';
  static const int databaseVersion = 1;

  // Network
  static const String defaultServerUrl = 'http://localhost:9925';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Durations
  static const int shortAnimationMs = 150;
  static const int mediumAnimationMs = 300;
  static const int longAnimationMs = 500;

  // Recipe Constants
  static const List<String> difficultyLevels = ['Easy', 'Medium', 'Hard'];
  static const List<String> defaultCategories = [
    'Breakfast',
    'Lunch', 
    'Dinner',
    'Dessert',
    'Snack',
    'Appetizer',
    'Side Dish',
    'Beverage',
  ];

  // Image Constants
  static const int maxImageSizeMB = 10;
  static const int imageQuality = 85;
  static const double maxImageWidth = 1920;
  static const double maxImageHeight = 1080;

  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  static const String timeoutErrorMessage = 'Request timeout. Please check your connection and try again.';
}