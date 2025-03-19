// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/firebase_options.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/datasources/local/local_storage.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';
import 'package:foodkie/presentation/screens/auth/splash_screen.dart';

// Data sources
import 'package:foodkie/data/datasources/remote/auth_remote_source.dart';
import 'package:foodkie/data/datasources/remote/category_remote_source.dart';
import 'package:foodkie/data/datasources/remote/food_remote_source.dart';
import 'package:foodkie/data/datasources/remote/order_remote_source.dart';
import 'package:foodkie/data/datasources/remote/table_remote_source.dart';

// Repositories
import 'package:foodkie/data/repositories/auth_repository_impl.dart';
import 'package:foodkie/data/repositories/category_repository_impl.dart';
import 'package:foodkie/data/repositories/food_repository_impl.dart';
import 'package:foodkie/data/repositories/order_repository_impl.dart';
import 'package:foodkie/data/repositories/table_repository_impl.dart';

// Auth use cases
import 'package:foodkie/domain/usecases/auth/change_password_usecase.dart';
import 'package:foodkie/domain/usecases/auth/forgot_password_usecase.dart';
import 'package:foodkie/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:foodkie/domain/usecases/auth/is_authenticated_usecase.dart';
import 'package:foodkie/domain/usecases/auth/is_email_verified_usecase.dart';
import 'package:foodkie/domain/usecases/auth/login_usecase.dart';
import 'package:foodkie/domain/usecases/auth/logout_usecase.dart';
import 'package:foodkie/domain/usecases/auth/register_usecase.dart';
import 'package:foodkie/domain/usecases/auth/resend_verification_email_usecase.dart';
import 'package:foodkie/domain/usecases/auth/update_user_profile_usecase.dart';

// Category use cases
import 'package:foodkie/domain/usecases/category/add_category_usecase.dart';
import 'package:foodkie/domain/usecases/category/delete_category_usecase.dart';
import 'package:foodkie/domain/usecases/category/get_categories_future_usecase.dart';
import 'package:foodkie/domain/usecases/category/get_categories_usecase.dart';
import 'package:foodkie/domain/usecases/category/get_category_by_id_usecase.dart';
import 'package:foodkie/domain/usecases/category/reorder_categories_usecase.dart';
import 'package:foodkie/domain/usecases/category/search_categories_usecase.dart';
import 'package:foodkie/domain/usecases/category/update_category_usecase.dart';

// Food use cases
import 'package:foodkie/domain/usecases/food/add_food_usecase.dart';
import 'package:foodkie/domain/usecases/food/delete_food_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_available_foods_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_food_by_id_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_foods_by_category_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_foods_usecase.dart';
import 'package:foodkie/domain/usecases/food/search_foods_usecase.dart';
import 'package:foodkie/domain/usecases/food/toggle_food_availability_usecase.dart';
import 'package:foodkie/domain/usecases/food/update_food_usecase.dart';

// Order use cases
import 'package:foodkie/domain/usecases/order/accept_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/add_item_to_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/cancel_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/create_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_kitchen_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_order_history_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_ready_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_table_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_waiter_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/mark_order_ready_usecase.dart';
import 'package:foodkie/domain/usecases/order/mark_order_served_usecase.dart';
import 'package:foodkie/domain/usecases/order/remove_item_from_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/serve_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/start_preparing_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/update_item_quantity_usecase.dart';
import 'package:foodkie/domain/usecases/order/update_order_status_usecase.dart';

// Table use cases
import 'package:foodkie/domain/usecases/table/add_table_usecase.dart';
import 'package:foodkie/domain/usecases/table/batch_update_tables_usecase.dart';
import 'package:foodkie/domain/usecases/table/cancel_reservation_usecase.dart';
import 'package:foodkie/domain/usecases/table/delete_table_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_available_tables_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_table_by_id_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_table_by_number_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_tables_by_status_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_tables_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_tables_with_capacity_usecase.dart';
import 'package:foodkie/domain/usecases/table/reserve_table_usecase.dart';
import 'package:foodkie/domain/usecases/table/update_table_status_usecase.dart';
import 'package:foodkie/domain/usecases/table/update_table_usecase.dart';

import 'core/constants/route_constants.dart';
import 'core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local storage
  await LocalStorage.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Create data sources
  final authRemoteSource = AuthRemoteSource();
  final categoryRemoteSource = CategoryRemoteSource();
  final foodRemoteSource = FoodRemoteSource();
  final orderRemoteSource = OrderRemoteSource();
  final tableRemoteSource = TableRemoteSource();

  // Create repositories
  final authRepository = AuthRepositoryImpl(authRemoteSource);
  final categoryRepository = CategoryRepositoryImpl(categoryRemoteSource);
  final foodRepository = FoodRepositoryImpl(foodRemoteSource);
  final orderRepository = OrderRepositoryImpl(orderRemoteSource);
  final tableRepository = TableRepositoryImpl(tableRemoteSource);

  // Create auth use cases
  final changePasswordUseCase = ChangePasswordUseCase(authRepository);
  final forgotPasswordUseCase = ForgotPasswordUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);
  final isAuthenticatedUseCase = IsAuthenticatedUseCase(authRepository);
  final isEmailVerifiedUseCase = IsEmailVerifiedUseCase(authRepository);
  final loginUseCase = LoginUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final resendVerificationEmailUseCase = ResendVerificationEmailUseCase(authRepository);
  final updateUserProfileUseCase = UpdateUserProfileUseCase(authRepository);

  // Create category use cases
  final addCategoryUseCase = AddCategoryUseCase(categoryRepository);
  final deleteCategoryUseCase = DeleteCategoryUseCase(categoryRepository);
  final getCategoriesFutureUseCase = GetCategoriesFutureUseCase(categoryRepository);
  final getCategoriesUseCase = GetCategoriesUseCase(categoryRepository);
  final getCategoryByIdUseCase = GetCategoryByIdUseCase(categoryRepository);
  final reorderCategoriesUseCase = ReorderCategoriesUseCase(categoryRepository);
  final searchCategoriesUseCase = SearchCategoriesUseCase(categoryRepository);
  final updateCategoryUseCase = UpdateCategoryUseCase(categoryRepository);

  // Create food use cases
  final addFoodUseCase = AddFoodUseCase(foodRepository);
  final deleteFoodUseCase = DeleteFoodUseCase(foodRepository);
  final getAvailableFoodsUseCase = GetAvailableFoodsUseCase(foodRepository);
  final getFoodByIdUseCase = GetFoodByIdUseCase(foodRepository);
  final getFoodsByCategoryUseCase = GetFoodsByCategoryUseCase(foodRepository);
  final getFoodsUseCase = GetFoodsUseCase(foodRepository);
  final searchFoodsUseCase = SearchFoodsUseCase(foodRepository);
  final toggleFoodAvailabilityUseCase = ToggleFoodAvailabilityUseCase(foodRepository);
  final updateFoodUseCase = UpdateFoodUseCase(foodRepository);

  // Create order use cases
  final acceptOrderUseCase = AcceptOrderUseCase(orderRepository);
  final addItemToOrderUseCase = AddItemToOrderUseCase(orderRepository);
  final cancelOrderUseCase = CancelOrderUseCase(orderRepository);
  final createOrderUseCase = CreateOrderUseCase(orderRepository);
  final getKitchenOrdersUseCase = GetKitchenOrdersUseCase(orderRepository);
  final getOrderHistoryUseCase = GetOrderHistoryUseCase(orderRepository);
  final getOrderUseCase = GetOrderUseCase(orderRepository);
  final getReadyOrdersUseCase = GetReadyOrdersUseCase(orderRepository);
  final getTableOrdersUseCase = GetTableOrdersUseCase(orderRepository);
  final getWaiterOrdersUseCase = GetWaiterOrdersUseCase(orderRepository);
  final markOrderReadyUseCase = MarkOrderReadyUseCase(orderRepository);
  final markOrderServedUseCase = MarkOrderServedUseCase(orderRepository);
  final removeItemFromOrderUseCase = RemoveItemFromOrderUseCase(orderRepository);
  final serveOrderUseCase = ServeOrderUseCase(orderRepository);
  final startPreparingOrderUseCase = StartPreparingOrderUseCase(orderRepository);
  final updateItemQuantityUseCase = UpdateItemQuantityUseCase(orderRepository);
  final updateOrderStatusUseCase = UpdateOrderStatusUseCase(orderRepository);

  // Create table use cases
  final addTableUseCase = AddTableUseCase(tableRepository);
  final batchUpdateTablesUseCase = BatchUpdateTablesUseCase(tableRepository);
  final cancelReservationUseCase = CancelReservationUseCase(tableRepository);
  final deleteTableUseCase = DeleteTableUseCase(tableRepository);
  final getAvailableTablesUseCase = GetAvailableTablesUseCase(tableRepository);
  final getTableByIdUseCase = GetTableByIdUseCase(tableRepository);
  final getTableByNumberUseCase = GetTableByNumberUseCase(tableRepository);
  final getTablesByStatusUseCase = GetTablesByStatusUseCase(tableRepository);
  final getTablesUseCase = GetTablesUseCase(tableRepository);
  final getTablesWithCapacityUseCase = GetTablesWithCapacityUseCase(tableRepository);
  final reserveTableUseCase = ReserveTableUseCase(tableRepository);
  final updateTableStatusUseCase = UpdateTableStatusUseCase(tableRepository);
  final updateTableUseCase = UpdateTableUseCase(tableRepository);

  runApp(MyApp(
    // Auth use cases
    changePasswordUseCase: changePasswordUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
    isAuthenticatedUseCase: isAuthenticatedUseCase,
    isEmailVerifiedUseCase: isEmailVerifiedUseCase,
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
    registerUseCase: registerUseCase,
    resendVerificationEmailUseCase: resendVerificationEmailUseCase,
    updateUserProfileUseCase: updateUserProfileUseCase,

    // Category use cases
    addCategoryUseCase: addCategoryUseCase,
    deleteCategoryUseCase: deleteCategoryUseCase,
    getCategoriesFutureUseCase: getCategoriesFutureUseCase,
    getCategoriesUseCase: getCategoriesUseCase,
    getCategoryByIdUseCase: getCategoryByIdUseCase,
    reorderCategoriesUseCase: reorderCategoriesUseCase,
    searchCategoriesUseCase: searchCategoriesUseCase,
    updateCategoryUseCase: updateCategoryUseCase,

    // Food use cases
    addFoodUseCase: addFoodUseCase,
    deleteFoodUseCase: deleteFoodUseCase,
    getAvailableFoodsUseCase: getAvailableFoodsUseCase,
    getFoodByIdUseCase: getFoodByIdUseCase,
    getFoodsByCategoryUseCase: getFoodsByCategoryUseCase,
    getFoodsUseCase: getFoodsUseCase,
    searchFoodsUseCase: searchFoodsUseCase,
    toggleFoodAvailabilityUseCase: toggleFoodAvailabilityUseCase,
    updateFoodUseCase: updateFoodUseCase,

    // Order use cases
    acceptOrderUseCase: acceptOrderUseCase,
    addItemToOrderUseCase: addItemToOrderUseCase,
    cancelOrderUseCase: cancelOrderUseCase,
    createOrderUseCase: createOrderUseCase,
    getKitchenOrdersUseCase: getKitchenOrdersUseCase,
    getOrderHistoryUseCase: getOrderHistoryUseCase,
    getOrderUseCase: getOrderUseCase,
    getReadyOrdersUseCase: getReadyOrdersUseCase,
    getTableOrdersUseCase: getTableOrdersUseCase,
    getWaiterOrdersUseCase: getWaiterOrdersUseCase,
    markOrderReadyUseCase: markOrderReadyUseCase,
    markOrderServedUseCase: markOrderServedUseCase,
    removeItemFromOrderUseCase: removeItemFromOrderUseCase,
    serveOrderUseCase: serveOrderUseCase,
    startPreparingOrderUseCase: startPreparingOrderUseCase,
    updateItemQuantityUseCase: updateItemQuantityUseCase,
    updateOrderStatusUseCase: updateOrderStatusUseCase,

    // Table use cases
    addTableUseCase: addTableUseCase,
    batchUpdateTablesUseCase: batchUpdateTablesUseCase,
    cancelReservationUseCase: cancelReservationUseCase,
    deleteTableUseCase: deleteTableUseCase,
    getAvailableTablesUseCase: getAvailableTablesUseCase,
    getTableByIdUseCase: getTableByIdUseCase,
    getTableByNumberUseCase: getTableByNumberUseCase,
    getTablesByStatusUseCase: getTablesByStatusUseCase,
    getTablesUseCase: getTablesUseCase,
    getTablesWithCapacityUseCase: getTablesWithCapacityUseCase,
    reserveTableUseCase: reserveTableUseCase,
    updateTableStatusUseCase: updateTableStatusUseCase,
    updateTableUseCase: updateTableUseCase,
  ));
}

class MyApp extends StatelessWidget {
  // Auth use cases
  final ChangePasswordUseCase changePasswordUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final IsAuthenticatedUseCase isAuthenticatedUseCase;
  final IsEmailVerifiedUseCase isEmailVerifiedUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final RegisterUseCase registerUseCase;
  final ResendVerificationEmailUseCase resendVerificationEmailUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;

  // Category use cases
  final AddCategoryUseCase addCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetCategoriesFutureUseCase getCategoriesFutureUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetCategoryByIdUseCase getCategoryByIdUseCase;
  final ReorderCategoriesUseCase reorderCategoriesUseCase;
  final SearchCategoriesUseCase searchCategoriesUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;

  // Food use cases
  final AddFoodUseCase addFoodUseCase;
  final DeleteFoodUseCase deleteFoodUseCase;
  final GetAvailableFoodsUseCase getAvailableFoodsUseCase;
  final GetFoodByIdUseCase getFoodByIdUseCase;
  final GetFoodsByCategoryUseCase getFoodsByCategoryUseCase;
  final GetFoodsUseCase getFoodsUseCase;
  final SearchFoodsUseCase searchFoodsUseCase;
  final ToggleFoodAvailabilityUseCase toggleFoodAvailabilityUseCase;
  final UpdateFoodUseCase updateFoodUseCase;

  // Order use cases
  final AcceptOrderUseCase acceptOrderUseCase;
  final AddItemToOrderUseCase addItemToOrderUseCase;
  final CancelOrderUseCase cancelOrderUseCase;
  final CreateOrderUseCase createOrderUseCase;
  final GetKitchenOrdersUseCase getKitchenOrdersUseCase;
  final GetOrderHistoryUseCase getOrderHistoryUseCase;
  final GetOrderUseCase getOrderUseCase;
  final GetReadyOrdersUseCase getReadyOrdersUseCase;
  final GetTableOrdersUseCase getTableOrdersUseCase;
  final GetWaiterOrdersUseCase getWaiterOrdersUseCase;
  final MarkOrderReadyUseCase markOrderReadyUseCase;
  final MarkOrderServedUseCase markOrderServedUseCase;
  final RemoveItemFromOrderUseCase removeItemFromOrderUseCase;
  final ServeOrderUseCase serveOrderUseCase;
  final StartPreparingOrderUseCase startPreparingOrderUseCase;
  final UpdateItemQuantityUseCase updateItemQuantityUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;

  // Table use cases
  final AddTableUseCase addTableUseCase;
  final BatchUpdateTablesUseCase batchUpdateTablesUseCase;
  final CancelReservationUseCase cancelReservationUseCase;
  final DeleteTableUseCase deleteTableUseCase;
  final GetAvailableTablesUseCase getAvailableTablesUseCase;
  final GetTableByIdUseCase getTableByIdUseCase;
  final GetTableByNumberUseCase getTableByNumberUseCase;
  final GetTablesByStatusUseCase getTablesByStatusUseCase;
  final GetTablesUseCase getTablesUseCase;
  final GetTablesWithCapacityUseCase getTablesWithCapacityUseCase;
  final ReserveTableUseCase reserveTableUseCase;
  final UpdateTableStatusUseCase updateTableStatusUseCase;
  final UpdateTableUseCase updateTableUseCase;

  const MyApp({
    Key? key,
    // Auth use cases
    required this.changePasswordUseCase,
    required this.forgotPasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.isAuthenticatedUseCase,
    required this.isEmailVerifiedUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.registerUseCase,
    required this.resendVerificationEmailUseCase,
    required this.updateUserProfileUseCase,

    // Category use cases
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getCategoriesFutureUseCase,
    required this.getCategoriesUseCase,
    required this.getCategoryByIdUseCase,
    required this.reorderCategoriesUseCase,
    required this.searchCategoriesUseCase,
    required this.updateCategoryUseCase,

    // Food use cases
    required this.addFoodUseCase,
    required this.deleteFoodUseCase,
    required this.getAvailableFoodsUseCase,
    required this.getFoodByIdUseCase,
    required this.getFoodsByCategoryUseCase,
    required this.getFoodsUseCase,
    required this.searchFoodsUseCase,
    required this.toggleFoodAvailabilityUseCase,
    required this.updateFoodUseCase,

    // Order use cases
    required this.acceptOrderUseCase,
    required this.addItemToOrderUseCase,
    required this.cancelOrderUseCase,
    required this.createOrderUseCase,
    required this.getKitchenOrdersUseCase,
    required this.getOrderHistoryUseCase,
    required this.getOrderUseCase,
    required this.getReadyOrdersUseCase,
    required this.getTableOrdersUseCase,
    required this.getWaiterOrdersUseCase,
    required this.markOrderReadyUseCase,
    required this.markOrderServedUseCase,
    required this.removeItemFromOrderUseCase,
    required this.serveOrderUseCase,
    required this.startPreparingOrderUseCase,
    required this.updateItemQuantityUseCase,
    required this.updateOrderStatusUseCase,

    // Table use cases
    required this.addTableUseCase,
    required this.batchUpdateTablesUseCase,
    required this.cancelReservationUseCase,
    required this.deleteTableUseCase,
    required this.getAvailableTablesUseCase,
    required this.getTableByIdUseCase,
    required this.getTableByNumberUseCase,
    required this.getTablesByStatusUseCase,
    required this.getTablesUseCase,
    required this.getTablesWithCapacityUseCase,
    required this.reserveTableUseCase,
    required this.updateTableStatusUseCase,
    required this.updateTableUseCase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth provider with use cases
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
            isAuthenticatedUseCase: isAuthenticatedUseCase,
            forgotPasswordUseCase: forgotPasswordUseCase,
            changePasswordUseCase: changePasswordUseCase,
            updateUserProfileUseCase: updateUserProfileUseCase,
          ),
        ),

        // Category provider with use cases
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(
            getCategoriesUseCase: getCategoriesUseCase,
            getCategoryByIdUseCase: getCategoryByIdUseCase,
            addCategoryUseCase: addCategoryUseCase,
            updateCategoryUseCase: updateCategoryUseCase,
            deleteCategoryUseCase: deleteCategoryUseCase,
            reorderCategoriesUseCase: reorderCategoriesUseCase,
            searchCategoriesUseCase: searchCategoriesUseCase,
          ),
        ),

        // Food provider with use cases
        ChangeNotifierProvider(
          create: (_) => FoodItemProvider(
            getFoodsUseCase: getFoodsUseCase,
            getFoodsByCategoryUseCase: getFoodsByCategoryUseCase,
            getFoodByIdUseCase: getFoodByIdUseCase,
            getAvailableFoodsUseCase: getAvailableFoodsUseCase,
            addFoodUseCase: addFoodUseCase,
            updateFoodUseCase: updateFoodUseCase,
            deleteFoodUseCase: deleteFoodUseCase,
            toggleFoodAvailabilityUseCase: toggleFoodAvailabilityUseCase,
            searchFoodsUseCase: searchFoodsUseCase,
          ),
        ),

        // Order provider with use cases
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            createOrderUseCase: createOrderUseCase,
            getOrderUseCase: getOrderUseCase,
            getKitchenOrdersUseCase: getKitchenOrdersUseCase,
            getReadyOrdersUseCase: getReadyOrdersUseCase,
            getWaiterOrdersUseCase: getWaiterOrdersUseCase,
            getTableOrdersUseCase: getTableOrdersUseCase,
            getOrderHistoryUseCase: getOrderHistoryUseCase,
            updateOrderStatusUseCase: updateOrderStatusUseCase,
            addItemToOrderUseCase: addItemToOrderUseCase,
            removeItemFromOrderUseCase: removeItemFromOrderUseCase,
            updateItemQuantityUseCase: updateItemQuantityUseCase,
            acceptOrderUseCase: acceptOrderUseCase,
            startPreparingOrderUseCase: startPreparingOrderUseCase,
            markOrderReadyUseCase: markOrderReadyUseCase,
            markOrderServedUseCase: markOrderServedUseCase,
            cancelOrderUseCase: cancelOrderUseCase,
          ),
        ),

        // Table provider with use cases
        ChangeNotifierProvider(
          create: (_) => TableProvider(
            getTablesUseCase: getTablesUseCase,
            getAvailableTablesUseCase: getAvailableTablesUseCase,
            getTablesByStatusUseCase: getTablesByStatusUseCase,
            getTableByIdUseCase: getTableByIdUseCase,
            getTableByNumberUseCase: getTableByNumberUseCase,
            getTablesWithCapacityUseCase: getTablesWithCapacityUseCase,
            addTableUseCase: addTableUseCase,
            updateTableUseCase: updateTableUseCase,
            deleteTableUseCase: deleteTableUseCase,
            updateTableStatusUseCase: updateTableStatusUseCase,
            batchUpdateTablesUseCase: batchUpdateTablesUseCase,
            reserveTableUseCase: reserveTableUseCase,
            cancelReservationUseCase: cancelReservationUseCase,
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Foodkie',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: RouteConstants.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
            onUnknownRoute: AppRouter.onUnknownRoute,
            darkTheme: AppTheme.lightTheme,
            themeMode: ThemeMode.system,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}