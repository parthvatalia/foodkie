// presentation/screens/waiter/waiter_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/order_card.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';

class WaiterHomeScreen extends StatefulWidget {
  const WaiterHomeScreen({Key? key}) : super(key: key);

  @override
  State<WaiterHomeScreen> createState() => _WaiterHomeScreenState();
}

class _WaiterHomeScreenState extends State<WaiterHomeScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<Order> _activeOrders = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        // Load active orders for this waiter
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        orderProvider.getActiveWaiterOrdersStream(user.id)?.listen(
              (orders) {
            if (mounted) {
              setState(() {
                _activeOrders = orders;
                _isLoading = false;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading orders: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not found'),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text(
          'Waiter Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.notification);
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: CustomDrawer(
        user: user,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Handle navigation based on drawer item selection
          switch (index) {
            case 0: // Home
              break;
            case 1: // Order History
              Navigator.pushNamed(context, RouteConstants.waiterOrderHistory);
              break;
            case 2: // Profile
              Navigator.pushNamed(context, RouteConstants.waiterProfile);
              break;
            case 3: // Settings
              Navigator.pushNamed(context, RouteConstants.settings);
              break;
            case 4: // Help
              Navigator.pushNamed(context, RouteConstants.help);
              break;
          }
        },
        items:  [
          DrawerItem(icon: Icons.home, title: 'Home'),
          DrawerItem(icon: Icons.history, title: 'Order History'),
          DrawerItem(icon: Icons.person, title: 'Profile'),
          DrawerItem(icon: Icons.settings, title: 'Settings'),
          DrawerItem(icon: Icons.help_outline, title: 'Help'),
        ],
      ),
      body: _buildBody(user),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, RouteConstants.waiterTableSelection);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildBody(UserModel user) {
    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: _isLoading
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              FadeAnimation(
                delay: 0.1,
                child: Text(
                  'Welcome, ${user.name}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              FadeAnimation(
                delay: 0.2,
                child: Text(
                  'Here\'s an overview of your active orders',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              FadeAnimation(
                delay: 0.3,
                child: _buildQuickActions(),
              ),

              const SizedBox(height: 24),

              // Active Orders
              FadeAnimation(
                delay: 0.4,
                child: _buildOrdersSection(),
              ),

              // Add some extra space at the bottom for the FAB
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.table_restaurant,
                title: 'Select Table',
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.waiterTableSelection);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.search,
                title: 'Search Menu',
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.waiterSearchFood);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: Icons.history,
                title: 'Order History',
                onTap: () {
                  Navigator.pushNamed(context, RouteConstants.waiterOrderHistory);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Orders',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_activeOrders.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteConstants.waiterOrderHistory);
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _activeOrders.isEmpty
            ? EmptyStateWidget(
          message: 'No active orders',
          icon: Icons.receipt_long,
          actionLabel: 'Create Order',
          onAction: () {
            Navigator.pushNamed(context, RouteConstants.waiterTableSelection);
          },
        )
            : Column(
          children:_activeOrders.isNotEmpty? _activeOrders.map((order) {
            return OrderCard(
              order: order,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteConstants.waiterOrderDetail,
                  arguments: order.id,
                );
              },
              showDetails: false,
              showActions: false,
            );
          }).toList():[],
        ),
      ],
    );
  }
}