// presentation/screens/kitchen/kitchen_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/order_card.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_order_detail_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_order_history_screen.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_profile_screen.dart';

import '../../../core/constants/route_constants.dart';

class KitchenHomeScreen extends StatefulWidget {
  const KitchenHomeScreen({Key? key}) : super(key: key);

  @override
  State<KitchenHomeScreen> createState() => _KitchenHomeScreenState();
}

class _KitchenHomeScreenState extends State<KitchenHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });

    // Load orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      orderProvider.loadKitchenOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onOrderTap(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KitchenOrderDetailScreen(order: order),
      ),
    );
  }

  Future<void> _onAcceptOrder(String orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.acceptOrder(orderId);
  }

  Future<void> _onStartPreparing(String orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.startPreparingOrder(orderId);
  }

  Future<void> _onMarkReady(String orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.markOrderAsReady(orderId);
  }

  List<Order> _filterOrdersByStatus(List<Order> orders, OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringConstants.kitchenTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KitchenOrderHistoryScreen()),
              );
            },
            tooltip: 'Order History',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'Preparing'),
          ],
        ),
      ),
      drawer: user != null
          ? CustomDrawer(
        user: user,
        selectedIndex: 0,
        onItemSelected: (index) {
          switch (index) {
            case 0: // Home
              Navigator.pop(context);
              break;
            case 2: // Profile
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KitchenProfileScreen()),
              );
              break;
            case 1: // Order History
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KitchenOrderHistoryScreen()),
              );
              break;
            case 3: // Logout
            // Handled by CustomDrawer

              break;
          }
        },
        items:  [
          DrawerItem(icon: Icons.home, title: 'Dashboard'),
          DrawerItem(icon: Icons.history, title: 'Order History'),
          DrawerItem(icon: Icons.person, title: 'My Profile'),

        ],
      )
          : null,
      body: orderProvider.isLoading
          ? const LoadingWidget(message: 'Loading orders...')
          : orderProvider.errorMessage != null
          ? ErrorDisplayWidget(
        message: orderProvider.errorMessage ?? 'Failed to load orders',
        onRetry: () {
          orderProvider.loadKitchenOrders();
        },
      )
          : orderProvider.orders.isEmpty
          ? EmptyStateWidget(
        message: 'No orders to process at the moment',
        actionLabel: 'Refresh',
        onAction: () {
          orderProvider.loadKitchenOrders();
        },
      )
          : TabBarView(
        controller: _tabController,
        children: [
          // Pending Orders
          _buildOrderList(
            _filterOrdersByStatus(orderProvider.orders, OrderStatus.pending),
            onAccept: _onAcceptOrder,
          ),

          // Accepted Orders
          _buildOrderList(
            _filterOrdersByStatus(orderProvider.orders, OrderStatus.accepted),
            onStartPreparing: _onStartPreparing,
          ),

          // Preparing Orders
          _buildOrderList(
            _filterOrdersByStatus(orderProvider.orders, OrderStatus.preparing),
            onMarkReady: _onMarkReady,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
      List<Order> orders, {
        Function(String)? onAccept,
        Function(String)? onStartPreparing,
        Function(String)? onMarkReady,
      }) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(
        message: 'No orders in this category',
        useLottie: false,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () => _onOrderTap(order),
          showDetails: false,
          showActions: true,
          onAccept: onAccept,
          onPrepare: onStartPreparing,
          onReady: onMarkReady,
        );
      },
    );
  }
}