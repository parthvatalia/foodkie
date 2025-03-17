// core/constants/route_constants.dart

class RouteConstants {
  // Auth Routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String roleSelection = '/role-selection';

  // Manager Routes
  static const String managerDashboard = '/manager/dashboard';
  static const String managerCategoryList = '/manager/categories';
  static const String managerCategoryAdd = '/manager/categories/add';
  static const String managerCategoryEdit = '/manager/categories/edit';
  static const String managerFoodList = '/manager/foods';
  static const String managerFoodAdd = '/manager/foods/add';
  static const String managerFoodEdit = '/manager/foods/edit';
  static const String managerTableList = '/manager/tables';
  static const String managerTableAdd = '/manager/tables/add';
  static const String managerTableEdit = '/manager/tables/edit';
  static const String managerStaffList = '/manager/staff';
  static const String managerStaffAdd = '/manager/staff/add';
  static const String managerStaffEdit = '/manager/staff/edit';
  static const String managerReports = '/manager/reports';
  static const String managerAnalytics = '/manager/analytics';
  static const String managerSettings = '/manager/settings';
  static const String managerProfile = '/manager/profile';

  // Waiter Routes
  static const String waiterHome = '/waiter/home';
  static const String waiterTableSelection = '/waiter/tables';
  static const String waiterCategoryView = '/waiter/categories';
  static const String waiterFoodSelection = '/waiter/foods';
  static const String waiterOrderCart = '/waiter/cart';
  static const String waiterOrderConfirmation = '/waiter/order-confirmation';
  static const String waiterOrderDetail = '/waiter/order-detail';
  static const String waiterOrderHistory = '/waiter/order-history';
  static const String waiterSearchFood = '/waiter/search';
  static const String waiterProfile = '/waiter/profile';

  // Kitchen Routes
  static const String kitchenHome = '/kitchen/home';
  static const String kitchenOrderList = '/kitchen/orders';
  static const String kitchenOrderDetail = '/kitchen/order-detail';
  static const String kitchenOrderHistory = '/kitchen/order-history';
  static const String kitchenProfile = '/kitchen/profile';

  // Common Routes
  static const String notification = '/notification';
  static const String settings = '/settings';
  static const String profileEdit = '/profile/edit';
  static const String changePassword = '/change-password';
  static const String about = '/about';
  static const String help = '/help';
  static const String termsConditions = '/terms-conditions';
  static const String privacyPolicy = '/privacy-policy';
}