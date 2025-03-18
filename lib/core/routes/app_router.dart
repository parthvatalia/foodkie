// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/presentation/screens/auth/forgot_password_screen.dart';
import 'package:foodkie/presentation/screens/auth/login_screen.dart';
import 'package:foodkie/presentation/screens/auth/onboarding_screen.dart';
import 'package:foodkie/presentation/screens/auth/register_screen.dart';
import 'package:foodkie/presentation/screens/auth/role_selection_screen.dart';
import 'package:foodkie/presentation/screens/auth/splash_screen.dart';
import 'package:foodkie/presentation/screens/auth/verify_email_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_home_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_order_detail_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_order_history_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_profile_screen.dart';
import 'package:foodkie/presentation/screens/manager/analytics/analytics_screen.dart';
import 'package:foodkie/presentation/screens/manager/categories/add_category_screen.dart';
import 'package:foodkie/presentation/screens/manager/categories/category_list_screen.dart';
import 'package:foodkie/presentation/screens/manager/categories/edit_category_screen.dart';
import 'package:foodkie/presentation/screens/manager/dashboard/manager_dashboard_screen.dart';
import 'package:foodkie/presentation/screens/manager/food_items/add_food_screen.dart';
import 'package:foodkie/presentation/screens/manager/food_items/edit_food_screen.dart';
import 'package:foodkie/presentation/screens/manager/food_items/food_list_screen.dart';
import 'package:foodkie/presentation/screens/manager/reports/reports_screen.dart';
import 'package:foodkie/presentation/screens/manager/settings/manager_settings_screen.dart';
import 'package:foodkie/presentation/screens/manager/staff/add_staff_screen.dart';
import 'package:foodkie/presentation/screens/manager/staff/edit_staff_screen.dart';
import 'package:foodkie/presentation/screens/manager/staff/staff_list_screen.dart';
import 'package:foodkie/presentation/screens/manager/tables/add_table_screen.dart';
import 'package:foodkie/presentation/screens/manager/tables/edit_table_screen.dart';
import 'package:foodkie/presentation/screens/manager/tables/table_list_screen.dart';
import 'package:foodkie/presentation/screens/shared/about_screen.dart';
import 'package:foodkie/presentation/screens/shared/change_password_screen.dart';
import 'package:foodkie/presentation/screens/shared/edit_profile_screen.dart';
import 'package:foodkie/presentation/screens/shared/help_screen.dart';
import 'package:foodkie/presentation/screens/shared/notification_screen.dart';
import 'package:foodkie/presentation/screens/shared/privacy_policy_screen.dart';
import 'package:foodkie/presentation/screens/shared/terms_conditions_screen.dart';
import 'package:foodkie/presentation/screens/waiter/cart_screen.dart';
import 'package:foodkie/presentation/screens/waiter/food_selection_screen.dart';
import 'package:foodkie/presentation/screens/waiter/order_confirmation_screen.dart';
import 'package:foodkie/presentation/screens/waiter/order_detail_screen.dart';
import 'package:foodkie/presentation/screens/waiter/order_history_screen.dart';
import 'package:foodkie/presentation/screens/waiter/search_screen.dart';
import 'package:foodkie/presentation/screens/waiter/table_selection_screen.dart';
import 'package:foodkie/presentation/screens/waiter/waiter_home_screen.dart';

import '../enums/app_enums.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Extract arguments if available
    final args = settings.arguments;

    switch (settings.name) {
    // Auth Routes
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteConstants.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteConstants.register:
        UserRole? selectedRole;
        if (args is Map<String, dynamic> && args.containsKey('selectedRole')) {
          selectedRole = args['selectedRole'];
        }
        return MaterialPageRoute(builder: (_) => RegisterScreen(selectedRole: selectedRole));
      case RouteConstants.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case RouteConstants.verifyEmail:
        String email = '';
        if (args is Map<String, dynamic> && args.containsKey('email')) {
          email = args['email'];
        }
        return MaterialPageRoute(builder: (_) => VerifyEmailScreen(email: email));
      case RouteConstants.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

    // Manager Routes
      case RouteConstants.managerDashboard:
        return MaterialPageRoute(builder: (_) => const ManagerDashboardScreen());
      case RouteConstants.managerCategoryList:
        return MaterialPageRoute(builder: (_) => const CategoryListScreen());
      case RouteConstants.managerCategoryAdd:
        return MaterialPageRoute(builder: (_) => const AddCategoryScreen());
      case RouteConstants.managerCategoryEdit:
        Category category;
        if (args is Map<String, dynamic> && args.containsKey('category')) {
          category = args['category'];
        } else {
          throw ArgumentError('Category argument is required');
        }
        return MaterialPageRoute(builder: (_) => EditCategoryScreen(category: category));
      case RouteConstants.managerFoodList:
        return MaterialPageRoute(builder: (_) => const FoodListScreen());
      case RouteConstants.managerFoodAdd:
        return MaterialPageRoute(builder: (_) => const AddFoodScreen());
      case RouteConstants.managerFoodEdit:
        FoodItem foodItem;
        if (args is Map<String, dynamic> && args.containsKey('foodItem')) {
          foodItem = args['foodItem'];
        } else {
          throw ArgumentError('Food item argument is required');
        }
        return MaterialPageRoute(builder: (_) => EditFoodScreen(foodItem: foodItem));
      case RouteConstants.managerTableList:
        return MaterialPageRoute(builder: (_) => const TableListScreen());
      case RouteConstants.managerTableAdd:
        return MaterialPageRoute(builder: (_) => const AddTableScreen());
      case RouteConstants.managerTableEdit:
        String tableId = '';
        if (args is Map<String, dynamic> && args.containsKey('tableId')) {
          tableId = args['tableId'];
        }
        return MaterialPageRoute(builder: (_) => EditTableScreen(tableId: tableId));
      case RouteConstants.managerStaffList:
        return MaterialPageRoute(builder: (_) => const StaffListScreen());
      case RouteConstants.managerStaffAdd:
        return MaterialPageRoute(builder: (_) => const AddStaffScreen());
      case RouteConstants.managerStaffEdit:
        UserModel staff;
        if (args is Map<String, dynamic> && args.containsKey('staff')) {
          staff = args['staff'];
        } else {
          throw ArgumentError('Staff argument is required');
        }
        return MaterialPageRoute(builder: (_) => EditStaffScreen(staff: staff));
      case RouteConstants.managerReports:
        return MaterialPageRoute(builder: (_) => const ReportsScreen());
      case RouteConstants.managerAnalytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
      case RouteConstants.managerSettings:
        return MaterialPageRoute(builder: (_) => const ManagerSettingsScreen());

    // Waiter Routes
      case RouteConstants.waiterHome:
        return MaterialPageRoute(builder: (_) => const WaiterHomeScreen());
      case RouteConstants.waiterTableSelection:
        return MaterialPageRoute(builder: (_) => const TableSelectionScreen());
      case RouteConstants.waiterFoodSelection:
        return MaterialPageRoute(builder: (_) => const FoodSelectionScreen());
      case RouteConstants.waiterOrderCart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case RouteConstants.waiterOrderConfirmation:
        String orderId = '';
        if (args is String) {
          orderId = args;
        }
        return MaterialPageRoute(builder: (_) => OrderConfirmationScreen(orderId: orderId));
      case RouteConstants.waiterOrderDetail:
        String orderId = '';
        if (args is String) {
          orderId = args;
        }
        return MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: orderId));
      case RouteConstants.waiterOrderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case RouteConstants.waiterSearchFood:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

    // Kitchen Routes
      case RouteConstants.kitchenHome:
        return MaterialPageRoute(builder: (_) => const KitchenHomeScreen());
      case RouteConstants.kitchenOrderDetail:
        Order order;
        if (args is Map<String, dynamic> && args.containsKey('order')) {
          order = args['order'];
        } else if (args is Order) {
          order = args;
        } else {
          throw ArgumentError('Order argument is required');
        }
        return MaterialPageRoute(builder: (_) => KitchenOrderDetailScreen(order: order));
      case RouteConstants.kitchenOrderHistory:
        return MaterialPageRoute(builder: (_) => const KitchenOrderHistoryScreen());
      case RouteConstants.kitchenProfile:
        return MaterialPageRoute(builder: (_) => const KitchenProfileScreen());

    // Common Routes
      case RouteConstants.notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case RouteConstants.profileEdit:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case RouteConstants.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case RouteConstants.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case RouteConstants.help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      case RouteConstants.termsConditions:
        return MaterialPageRoute(builder: (_) => const TermsConditionsScreen());
      case RouteConstants.privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      default:
      // Return a default "not found" route
        return _buildNotFoundRoute(settings);
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return _buildErrorRoute(settings);
  }

  static Route<dynamic> _buildNotFoundRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Route Not Found')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              const SizedBox(height: 16),
              const Text(
                'Page not found',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Route "${settings.name}" does not exist'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(RouteConstants.splash),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Route<dynamic> _buildErrorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'The requested route could not be found',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(RouteConstants.splash),
                child: const Text('Return to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}