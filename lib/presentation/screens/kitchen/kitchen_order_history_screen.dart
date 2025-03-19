// presentation/screens/kitchen/kitchen_order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/string_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/error_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/order_card.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/screens/kitchen/kitchen_order_detail_screen.dart';
import 'package:intl/intl.dart';

class KitchenOrderHistoryScreen extends StatefulWidget {
  const KitchenOrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<KitchenOrderHistoryScreen> createState() => _KitchenOrderHistoryScreenState();
}

class _KitchenOrderHistoryScreenState extends State<KitchenOrderHistoryScreen> {
  List<Order> _historyOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedFilter = 'All';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final orders = await orderProvider.getOrderHistory(limit: 100);

      if (mounted) {
        setState(() {
          _historyOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onOrderTap(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KitchenOrderDetailScreen(order: order),
      ),
    ).then((_) => _loadOrderHistory()); // Refresh on return
  }

  List<Order> _getFilteredOrders() {
    List<Order> filteredOrders = [..._historyOrders];

    // Filter by status
    if (_selectedFilter != 'All') {
      final OrderStatus status = _selectedFilter == 'Served'
          ? OrderStatus.served
          : OrderStatus.cancelled;

      filteredOrders = filteredOrders.where((order) => order.status == status).toList();
    }

    // Filter by date
    if (_selectedDate != null) {
      filteredOrders = filteredOrders.where((order) {
        final orderDate = DateTime(
          order.createdAt.year,
          order.createdAt.month,
          order.createdAt.day,
        );

        final selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );

        return orderDate.isAtSameMomentAs(selectedDate);
      }).toList();
    }

    return filteredOrders;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrderHistory,
            tooltip: 'Refresh',
          ),
          if (_selectedFilter != 'All' || _selectedDate != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _clearFilters,
              tooltip: 'Clear Filters',
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Loading order history...')
          : _errorMessage != null
          ? ErrorDisplayWidget(
        message: _errorMessage ?? 'Failed to load order history',
        onRetry: _loadOrderHistory,
      )
          : _historyOrders.isEmpty
          ? const EmptyStateWidget(
        message: 'No order history found',
        useLottie: false,
      )
          : Column(
        children: [
          // Filter options
          _buildFilterSection(),

          // Order count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Orders: ${filteredOrders.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedDate != null)
                  Text(
                    'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          // Order list
          Expanded(
            child: filteredOrders.isEmpty
                ? const EmptyStateWidget(
              message: 'No orders match your filters',
              useLottie: false,
            )
                : _buildOrderHistoryList(filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status Filter
          Expanded(
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Status',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: _selectedFilter,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Served', child: Text('Served')),
                DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                  });
                }
              },
            ),
          ),

          const SizedBox(width: 8),

          // Date Filter
          OutlinedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_month),
            label: Text(_selectedDate == null ? 'Date' : 'Date ✓'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(
                color: _selectedDate != null ? AppTheme.primaryColor : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryList(List<Order> orders) {
    // Group orders by date
    final groupedOrders = <String, List<Order>>{};
    for (final order in orders) {
      final dateStr = DateFormat('MMMM dd, yyyy').format(order.createdAt);
      if (!groupedOrders.containsKey(dateStr)) {
        groupedOrders[dateStr] = [];
      }
      groupedOrders[dateStr]!.add(order);
    }

    // Sort the dates in descending order (most recent first)
    final sortedDates = groupedOrders.keys.toList()
      ..sort((a, b) => DateFormat('MMMM dd, yyyy').parse(b).compareTo(
        DateFormat('MMMM dd, yyyy').parse(a),
      ));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateOrders = groupedOrders[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            if (_selectedDate?.isAtSameMomentAs(DateFormat('MMMM dd, yyyy').parse(date)) ?? true)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

            // Orders for this date
            ...dateOrders.map((order) => OrderCard(
              order: order,
              onTap: () => _onOrderTap(order),
              showDetails: false,
              showActions: false,
            )),
          ],
        );
      },
    );
  }
}