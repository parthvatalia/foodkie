// core/constants/assets_constants.dart

class AssetsConstants {
  // Image Paths
  static const String _imgBasePath = 'assets/images';
  static const String _iconBasePath = 'assets/icons';
  static const String _animationBasePath = 'assets/animations';

  // Logo Images
  static const String logoFullPath = '$_imgBasePath/logo_full.png';
  static const String logoIconPath = '$_imgBasePath/logo_icon.png';
  static const String logoTextPath = '$_imgBasePath/logo_text.png';

  // Authentication Images
  static const String loginBgPath = '$_imgBasePath/login_bg.jpg';
  static const String welcomeImagePath = '$_imgBasePath/welcome.png';

  // Placeholder Images
  static const String foodPlaceholderPath = '$_imgBasePath/food_placeholder.jpg';
  static const String categoryPlaceholderPath = '$_imgBasePath/category_placeholder.jpg';
  static const String userPlaceholderPath = '$_imgBasePath/user_placeholder.jpg';

  // Onboarding Images
  static const String onboarding1Path = '$_imgBasePath/onboarding_1.png';
  static const String onboarding2Path = '$_imgBasePath/onboarding_2.png';
  static const String onboarding3Path = '$_imgBasePath/onboarding_3.png';

  // Icons
  static const String menuIconPath = '$_iconBasePath/menu_icon.png';
  static const String waiterIconPath = '$_iconBasePath/waiter_icon.png';
  static const String kitchenIconPath = '$_iconBasePath/kitchen_icon.png';
  static const String managerIconPath = '$_iconBasePath/manager_icon.png';
  static const String categoryIconPath = '$_iconBasePath/category_icon.png';
  static const String tableIconPath = '$_iconBasePath/table_icon.png';
  static const String orderIconPath = '$_iconBasePath/order_icon.png';
  static const String foodIconPath = '$_iconBasePath/food_icon.png';
  static const String reportIconPath = '$_iconBasePath/report_icon.png';
  static const String settingsIconPath = '$_iconBasePath/settings_icon.png';

  // Animations (Lottie files)
  static const String loadingAnimationPath = '$_animationBasePath/loading.json';
  static const String successAnimationPath = '$_animationBasePath/success.json';
  static const String errorAnimationPath = '$_animationBasePath/error.json';
  static const String emptyAnimationPath = '$_animationBasePath/empty.json';
  static const String orderCompletedAnimationPath = '$_animationBasePath/order_completed.json';
  static const String foodPreparingAnimationPath = '$_animationBasePath/food_preparing.json';

  // Default Icons (Material Icons or custom path)
  static const String defaultErrorIcon = 'error_outline';
  static const String defaultSuccessIcon = 'check_circle_outline';
  static const String defaultWarningIcon = 'warning_amber_rounded';
  static const String defaultInfoIcon = 'info_outline';
}