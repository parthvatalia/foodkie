// core/constants/app_constants.dart

class AppConstants {
  // App Info
  static const String appName = 'Foodkie';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Firebase Collections
  static const String usersCollection = 'Users';
  static const String categoriesCollection = 'Categories';
  static const String foodItemsCollection = 'FoodItems';
  static const String tablesCollection = 'Tables';
  static const String ordersCollection = 'Orders';
  static const String orderItemsCollection = 'OrderItems';
  static const String paymentsCollection = 'Payments';

  // Firebase Storage Paths
  static const String userImagesPath = 'user_images';
  static const String categoryImagesPath = 'category_images';
  static const String foodImagesPath = 'food_images';

  // SharedPreferences Keys
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String userEmailKey = 'user_email';
  static const String userNameKey = 'user_name';
  static const String rememberMeKey = 'remember_me';
  static const String isDarkModeKey = 'is_dark_mode';
  static const String authTokenKey = 'auth_token';
  static const String lastSyncKey = 'last_sync';

  // Default Values
  static const int defaultCategoryOrder = 999;
  static const int defaultPreparationTime = 15; // minutes
  static const double defaultImageQuality = 0.8;
  static const int maxImageDimension = 1024;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration cacheDuration = Duration(days: 7);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultButtonHeight = 48.0;
  static const double fabBottomMargin = 16.0;
  static const double drawerWidth = 300.0;
  static const double appBarHeight = 56.0;

  // Animation Duration
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // Limits
  static const int maxCategoryNameLength = 30;
  static const int maxFoodNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const int maxNotesLength = 200;
  static const int searchMaxResults = 50;
  static const int maxItemsPerOrder = 100;
}