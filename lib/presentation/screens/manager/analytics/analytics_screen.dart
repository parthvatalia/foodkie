// presentation/screens/manager/analytics/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/extensions/context_extentions.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_drawer.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';

import '../../../../core/enums/app_enums.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimePeriod = 'Weekly';
  final List<String> _timePeriods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  List<Order> _orderHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrderHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final history = await orderProvider.getOrderHistory(limit: 1000);

      setState(() {
        _orderHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: StringConstants.analytics,
        showBackButton: false,
      ),
      drawer: CustomDrawer(
        user: user,
        selectedIndex: 6, // Assuming analytics is the 7th item in the drawer
        onItemSelected: (index) {
          // Handle navigation
        },
        items: [
          DrawerItem(
            icon: Icons.dashboard,
            title: StringConstants.dashboard,
          ),
          DrawerItem(
            icon: Icons.category,
            title: StringConstants.categories,
          ),
          DrawerItem(
            icon: Icons.restaurant_menu,
            title: StringConstants.foodItems,
          ),
          DrawerItem(
            icon: Icons.table_bar,
            title: StringConstants.tables,
          ),
          DrawerItem(
            icon: Icons.people,
            title: StringConstants.staff,
          ),
          DrawerItem(
            icon: Icons.receipt_long,
            title: StringConstants.reports,
          ),
          DrawerItem(
            icon: Icons.analytics,
            title: StringConstants.analytics,
          ),
          DrawerItem(
            icon: Icons.settings,
            title: StringConstants.settings,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading analytics data...');
    }

    if (_errorMessage != null) {
      return ErrorDisplayWidget(
        message: _errorMessage!,
        onRetry: _loadOrderHistory,
      );
    }

    if (_orderHistory.isEmpty) {
      return EmptyStateWidget(
        message: 'No order data available to generate analytics',
        actionLabel: 'Refresh',
        onAction: _loadOrderHistory,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTimePeriodSelector(),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSalesTab(),
              _buildPopularItemsTab(),
              _buildOrdersTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            'Time Period:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: _selectedTimePeriod,
                isExpanded: true,
                underline: const SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTimePeriod = newValue;
                    });
                  }
                },
                items: _timePeriods.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.grey.shade700,
        indicatorColor: AppTheme.primaryColor,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Sales', icon: Icon(Icons.attach_money)),
          Tab(text: 'Popular Items', icon: Icon(Icons.star)),
          Tab(text: 'Orders', icon: Icon(Icons.receipt)),
        ],
      ),
    );
  }

  Widget _buildSalesTab() {
    // Calculate sales analytics
    final salesData = _calculateSalesData();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(salesData),
            const SizedBox(height: 24),
            Text(
              'Sales Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSalesChart(salesData),
            const SizedBox(height: 24),
            Text(
              'Sales by Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItemsTab() {
    final popularItems = _calculatePopularItems();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Popular Items',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: popularItems.length,
              itemBuilder: (context, index) {
                final item = popularItems[index];
                return _buildPopularItemCard(
                  item['itemId'] as String,
                  item['count'] as int,
                  item['revenue'] as double,
                  index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    final orderTrends = _calculateOrderTrends();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderSummaryCards(),
            const SizedBox(height: 24),
            Text(
              'Order Trend',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderTrendChart(orderTrends),
            const SizedBox(height: 24),
            Text(
              'Average Order Completion Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderTimeAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(Map<String, dynamic> salesData) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Sales',
            NumberFormatter.formatCurrency(salesData['totalSales']),
            Icons.attach_money,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Orders',
            salesData['totalOrders'].toString(),
            Icons.receipt_long,
            AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Avg Order',
            NumberFormatter.formatCurrency(salesData['averageOrder']),
            Icons.shopping_cart,
            AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(Map<String, dynamic> salesData) {
    // This is a placeholder for the chart
    // In a real implementation, you would use a charting library like fl_chart or syncfusion_flutter_charts
    return Container(
      height: 250,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 60,
              color: AppTheme.primaryColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Sales trend visualization would appear here',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Data available for ${salesData['timePeriods'].length} periods',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    // Calculate order status breakdown
    final Map<OrderStatus, int> statusCounts = {};
    for (final order in _orderHistory) {
      statusCounts[order.status] = (statusCounts[order.status] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in statusCounts.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStatusName(entry.key),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${entry.value} orders',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: entry.value / _orderHistory.length,
                    backgroundColor: Colors.grey.shade200,
                    color: _getStatusColor(entry.key),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularItemCard(String itemId, int count, double revenue, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemId, // In a real app, you would get the name from the foodItem model
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Ordered $count times',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormatter.formatCurrency(revenue),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Revenue',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCards() {
    // Calculate order statistics
    final totalOrders = _orderHistory.length;
    final completedOrders = _orderHistory.where((order) =>
    order.status == OrderStatus.served).length;
    final cancelledOrders = _orderHistory.where((order) =>
    order.status == OrderStatus.cancelled).length;

    final completionRate = totalOrders > 0
        ? (completedOrders / totalOrders * 100).toStringAsFixed(1) + '%'
        : '0%';

    final cancellationRate = totalOrders > 0
        ? (cancelledOrders / totalOrders * 100).toStringAsFixed(1) + '%'
        : '0%';

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Completion Rate',
            completionRate,
            Icons.check_circle_outline,
            AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'Cancellation Rate',
            cancellationRate,
            Icons.cancel_outlined,
            AppTheme.errorColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderTrendChart(Map<String, List<int>> orderTrends) {
    // This is a placeholder for the chart
    return Container(
      height: 250,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 60,
              color: AppTheme.accentColor.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Order trend visualization would appear here',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Data available for ${orderTrends['dates']?.length ?? 0} periods',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeAnalysis() {
    // Calculate average time from order to ready, and ready to served
    final completedOrders = _orderHistory.where((order) =>
    order.status == OrderStatus.served).toList();

    // This is a placeholder - in a real app you would track timestamps for each status change
    const avgPreparationTime = '23 min';
    const avgDeliveryTime = '8 min';
    const avgTotalTime = '31 min';

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          _buildTimeStatRow('Order to Kitchen', avgPreparationTime),
          const Divider(height: 32),
          _buildTimeStatRow('Kitchen to Serving', avgDeliveryTime),
          const Divider(height: 32),
          _buildTimeStatRow('Total Order Time', avgTotalTime, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTimeStatRow(String label, String time, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isTotal ? FontWeight.bold : null,
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isTotal ? AppTheme.primaryColor : null,
          ),
        ),
      ],
    );
  }

  // Helper methods for data calculation
  Map<String, dynamic> _calculateSalesData() {
    double totalSales = 0;
    final List<DateTime> dates = [];
    final List<double> sales = [];

    for (final order in _orderHistory) {
      if (order.status != OrderStatus.cancelled) {
        totalSales += order.totalAmount;

        // In a real app, you would group by time period based on _selectedTimePeriod
        final date = order.createdAt;
        final existingIndex = dates.indexWhere((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);

        if (existingIndex >= 0) {
          sales[existingIndex] += order.totalAmount;
        } else {
          dates.add(date);
          sales.add(order.totalAmount);
        }
      }
    }

    final totalOrders = _orderHistory.where((order) =>
    order.status != OrderStatus.cancelled).length;

    final averageOrder = totalOrders > 0 ? totalSales / totalOrders : 0;

    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'averageOrder': averageOrder,
      'timePeriods': dates,
      'sales': sales,
    };
  }

  List<Map<String, dynamic>> _calculatePopularItems() {
    final Map<String, Map<String, dynamic>> itemCounts = {};

    for (final order in _orderHistory) {
      if (order.status != OrderStatus.cancelled) {
        for (final item in order.items) {
          if (!itemCounts.containsKey(item.foodItemId)) {
            itemCounts[item.foodItemId] = {
              'itemId': item.foodItemId,
              'count': 0,
              'revenue': 0.0,
            };
          }

          itemCounts[item.foodItemId]!['count'] =
              (itemCounts[item.foodItemId]!['count'] as int) + item.quantity;

          // This is a simplified approach - in a real app, you would calculate
          // using the actual price of each food item
          final estimatedItemPrice = order.totalAmount / order.items.length;
          itemCounts[item.foodItemId]!['revenue'] =
              (itemCounts[item.foodItemId]!['revenue'] as double) +
                  (estimatedItemPrice * item.quantity);
        }
      }
    }

    final popularItems = itemCounts.values.toList();

    // Sort by count in descending order
    popularItems.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    // Take top 10 or less
    return popularItems.take(10).toList();
  }

  Map<String, List<int>> _calculateOrderTrends() {
    final Map<String, int> ordersByDate = {};
    final Map<String, int> completedByDate = {};
    final Map<String, int> cancelledByDate = {};

    for (final order in _orderHistory) {
      final dateStr = DateFormat('yyyy-MM-dd').format(order.createdAt);

      // Count all orders by date
      ordersByDate[dateStr] = (ordersByDate[dateStr] ?? 0) + 1;

      // Count completed and cancelled orders
      if (order.status == OrderStatus.served) {
        completedByDate[dateStr] = (completedByDate[dateStr] ?? 0) + 1;
      } else if (order.status == OrderStatus.cancelled) {
        cancelledByDate[dateStr] = (cancelledByDate[dateStr] ?? 0) + 1;
      }
    }

    // Sort dates
    final dates = ordersByDate.keys.toList()..sort();

    // Create lists for the chart
    final List<int> totalOrders = [];
    final List<int> completed = [];
    final List<int> cancelled = [];

    for (final date in dates) {
      totalOrders.add(ordersByDate[date] ?? 0);
      completed.add(completedByDate[date] ?? 0);
      cancelled.add(cancelledByDate[date] ?? 0);
    }

    return {
      'dates': dates.map((d) => DateFormat('yyyy-MM-dd').parse(d).millisecondsSinceEpoch).toList(),
      'totalOrders': totalOrders,
      'completed': completed,
      'cancelled': cancelled,
    };
  }

  String _getStatusName(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.blue;
      case OrderStatus.accepted:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.amber;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.served:
        return Colors.purple;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber.shade700; // Gold
    if (rank == 2) return Colors.grey.shade400; // Silver
    if (rank == 3) return Colors.brown.shade400; // Bronze
    return Colors.blue.shade400; // Others
  }
}