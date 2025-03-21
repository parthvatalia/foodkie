// presentation/screens/manager/dashboard/manager_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/category_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';
import 'package:foodkie/presentation/screens/manager/analytics/analytics_screen.dart';
import 'package:foodkie/presentation/screens/manager/categories/category_list_screen.dart';
import 'package:foodkie/presentation/screens/manager/food_items/food_list_screen.dart';
import 'package:foodkie/presentation/screens/manager/reports/reports_screen.dart';
import 'package:foodkie/presentation/screens/manager/settings/manager_settings_screen.dart';
import 'package:foodkie/presentation/screens/manager/staff/staff_list_screen.dart';
import 'package:foodkie/presentation/screens/manager/tables/table_list_screen.dart';
import 'package:foodkie/core/utils/number_formatter.dart';

import '../../../../core/enums/app_enums.dart';
import '../../../../data/models/table_model.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  bool _isLoading = true;
  int _categoryCount = 0;
  int _foodItemCount = 0;
  int _tableCount = 0;
  int _activeOrderCount = 0;
  double _todayRevenue = 0;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadCategoriesCount(),
        _loadFoodItemsCount(),
        _loadTablesCount(),
        _loadActiveOrdersCount(),
        _loadTodayRevenue(),
      ]);
    } catch (e) {
      // Error handling will be done in individual methods
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCategoriesCount() async {
    try {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final categories = await categoryProvider.getAllCategoriesFuture();
      if (mounted) {
        setState(() {
          _categoryCount = categories.length;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadFoodItemsCount() async {
    try {
      final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);
      final foodItems = await foodItemProvider.getAllFoodItemsFuture();
      if (mounted) {
        setState(() {
          _foodItemCount = foodItems.length;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadTablesCount() async {
    try {
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      final tables = await tableProvider.getAllTablesFuture();
      if (mounted) {
        setState(() {
          _tableCount = tables.length;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadActiveOrdersCount() async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final orders = await orderProvider.getOrderHistory();

      final activeOrders = orders.where((order) =>
      order.status != OrderStatus.served &&
          order.status != OrderStatus.cancelled
      ).toList();

      if (mounted) {
        setState(() {
          _activeOrderCount = activeOrders.length;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _loadTodayRevenue() async {
    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final orders = await orderProvider.getOrderHistory();

      // Filter orders for today and calculate total revenue
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final todayOrders = orders.where((order) {
        final orderDate = DateTime(
            order.createdAt.year,
            order.createdAt.month,
            order.createdAt.day
        );
        return orderDate.isAtSameMomentAs(today) && order.status == OrderStatus.served;
      }).toList();

      final revenue = todayOrders.fold(
          0.0,
              (sum, order) => sum + order.totalAmount
      );

      if (mounted) {
        setState(() {
          _todayRevenue = revenue;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0: // Dashboard (current screen)
        break;
      case 1: // Categories
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CategoryListScreen()),
        ).then((_) => _loadDashboardData());
        break;
      case 2: // Food Items.

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FoodListScreen()),
        ).then((_) => _loadDashboardData());
        break;
      case 3: // Tables
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TableListScreen()),
        ).then((_) => _loadDashboardData());
        break;
      case 4: // Staff
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StaffListScreen()),
        ).then((_) => _loadDashboardData());
        break;
      case 5: // Analytics
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
        );
        break;
      case 6: // Reports
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReportsScreen()),
        );
        break;
      case 7: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManagerSettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(StringConstants.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: user != null
          ? CustomDrawer(
        user: user,
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // Close the drawer
          _navigateToScreen(index);
        },
        items:  [
          DrawerItem(icon: Icons.dashboard, title: 'Dashboard'),
          DrawerItem(icon: Icons.category, title: 'Categories'),
          DrawerItem(icon: Icons.restaurant_menu, title: 'Food Items'),
          DrawerItem(icon: Icons.table_bar, title: 'Tables'),
          DrawerItem(icon: Icons.people, title: 'Staff'),
          DrawerItem(icon: Icons.analytics, title: 'Analytics'),
          DrawerItem(icon: Icons.summarize, title: 'Reports'),
          DrawerItem(icon: Icons.settings, title: 'Settings'),
        ],
      )
          : null,
      body: _isLoading
          ? const LoadingWidget(message: 'Loading dashboard data...')
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(user),

              const SizedBox(height: 24),

              // Stats Cards
              _buildStatsGrid(),

              const SizedBox(height: 24),

              // Quick Actions
              _buildQuickActions(),

              const SizedBox(height: 24),

              // Recent Activity
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(dynamic user) {
    final now = DateTime.now();
    String greeting;

    if (now.hour < 12) {
      greeting = 'Good Morning';
    } else if (now.hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, ${user?.name ?? 'Manager'}',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEEE, MMMM dd, yyyy').format(DateTime.now()),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Today\'s Revenue',
          value: NumberFormatter.formatCurrency(_todayRevenue),
          icon: Icons.monetization_on_rounded,
          color: Colors.green,
        ),
        _buildStatCard(
          title: 'Active Orders',
          value: _activeOrderCount.toString(),
          icon: Icons.receipt_long,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Food Items',
          value: _foodItemCount.toString(),
          icon: Icons.restaurant_menu,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Categories',
          value: _categoryCount.toString(),
          icon: Icons.category,
          color: Colors.purple,
        ),
        _buildStatCard(
          title: 'Tables',
          value: _tableCount.toString(),
          icon: Icons.table_bar,
          color: Colors.brown,
        ),
        _buildStatCard(
          title: 'Staff Members',
          value: '0', // Would need staff count from the provider
          icon: Icons.people,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.black54,width: 0.5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),

              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
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
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionButton(
              label: 'Add Food',
              icon: Icons.add_circle,
              color: AppTheme.primaryColor,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodListScreen(),
                ),
              ).then((_) => _loadDashboardData()),
            ),
            _buildActionButton(
              label: 'Add Category',
              icon: Icons.add_box,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryListScreen(),
                ),
              ).then((_) => _loadDashboardData()),
            ),
            _buildActionButton(
              label: 'Add Table',
              icon: Icons.add_business,
              color: Colors.brown,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TableListScreen(),
                ),
              ).then((_) => _loadDashboardData()),
            ),
            _buildActionButton(
              label: 'View Reports',
              icon: Icons.assessment,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: _fetchRecentActivity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading recent activity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final activities = snapshot.data ?? [];

            if (activities.isEmpty) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent activity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Recent orders and changes will appear here',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Display activities
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length > 5 ? 5 : activities.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return _buildActivityItem(activity);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  ListTile _buildActivityItem(Map<String, dynamic> activity) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: activity['color'] as Color,
        child: Icon(
          activity['icon'] as IconData,
          color: Colors.white,
          size: 20,
        ),
      ),
      title: Text(
        activity['title'] as String,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(activity['details'] as String),
      trailing: Text(
        activity['time'] as String,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  Future<List<dynamic>> _fetchRecentActivity() async {
    List<dynamic> activities = [];

    try {
      // Fetch recent orders
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final orders = await orderProvider.getOrderHistory(limit: 10);

      // Fetch updated food items (last 3 days)
      final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);
      final foodItems = await foodItemProvider.getAllFoodItemsFuture();

      // Filter for recently updated items (last 3 days)
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final recentFoodItems = foodItems.where((item) =>
          item.updatedAt.isAfter(threeDaysAgo)).toList();

      // Fetch tables
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      final tables = await tableProvider.getAllTablesFuture();

      // Fetch categories
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final categories = await categoryProvider.getAllCategoriesFuture();
      final recentCategories = categories.where((item) =>
          item.updatedAt.isAfter(threeDaysAgo)).toList();

      // Convert orders to activities
      for (final order in orders) {
        final table = tables.firstWhere(
              (t) => t.id == order.tableId,
          orElse: () => TableModel(
            id: 'unknown',
            number: 0,
            capacity: 0,
            status: TableStatus.available,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        String timeAgo = _getTimeAgo(order.updatedAt);

        if (order.isServed) {
          activities.add({
            'title': 'Order completed',
            'details': 'Table ${table.number} order served (${order.items.length} items)',
            'time': timeAgo,
            'icon': Icons.check_circle,
            'color': Colors.green,
            'timestamp': order.updatedAt,
          });
        } else if (order.isCancelled) {
          activities.add({
            'title': 'Order cancelled',
            'details': 'Table ${table.number} order cancelled',
            'time': timeAgo,
            'icon': Icons.cancel,
            'color': Colors.red,
            'timestamp': order.updatedAt,
          });
        } else if (order.isReady) {
          activities.add({
            'title': 'Order ready',
            'details': 'Table ${table.number} order is ready to serve',
            'time': timeAgo,
            'icon': Icons.room_service,
            'color': Colors.orange,
            'timestamp': order.updatedAt,
          });
        } else if (order.isPreparing) {
          activities.add({
            'title': 'Order in preparation',
            'details': 'Table ${table.number} order is being prepared',
            'time': timeAgo,
            'icon': Icons.restaurant,
            'color': Colors.amber,
            'timestamp': order.updatedAt,
          });
        } else {
          activities.add({
            'title': 'New order received',
            'details': 'Table ${table.number}, ${order.items.length} items',
            'time': timeAgo,
            'icon': Icons.receipt_long,
            'color': Colors.blue,
            'timestamp': order.createdAt,
          });
        }
      }

      // Add food item updates
      for (final item in recentFoodItems) {
        final timeAgo = _getTimeAgo(item.updatedAt);
        activities.add({
          'title': 'Food item updated',
          'details': '${item.name} has been updated',
          'time': timeAgo,
          'icon': Icons.edit,
          'color': Colors.blue,
          'timestamp': item.updatedAt,
        });
      }

      // Add category updates
      for (final category in recentCategories) {
        final timeAgo = _getTimeAgo(category.updatedAt);
        activities.add({
          'title': 'Category updated',
          'details': '${category.name} category has been updated',
          'time': timeAgo,
          'icon': Icons.category,
          'color': Colors.purple,
          'timestamp': category.updatedAt,
        });
      }

      // Add table status changes for tables that were updated recently
      final recentTables = tables.where((table) => table.updatedAt.isAfter(threeDaysAgo)).toList();
      for (final table in recentTables) {
        final timeAgo = _getTimeAgo(table.updatedAt);
        activities.add({
          'title': 'Table status changed',
          'details': 'Table ${table.number} marked as ${_getStatusText(table.status)}',
          'time': timeAgo,
          'icon': Icons.table_bar,
          'color': Colors.brown,
          'timestamp': table.updatedAt,
        });
      }

      // Sort activities by timestamp, most recent first
      activities.sort((a, b) {
        final aTime = a['timestamp'] as DateTime;
        final bTime = b['timestamp'] as DateTime;
        return bTime.compareTo(aTime);
      });

    } catch (e) {
      print('Error fetching recent activity: $e');
      // Return empty list on error
    }

    return activities;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd').format(dateTime);
    }
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'available';
      case TableStatus.occupied:
        return 'occupied';
      case TableStatus.reserved:
        return 'reserved';
    }
  }
}