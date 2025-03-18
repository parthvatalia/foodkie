
// presentation/screens/waiter/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/order_card.dart';
import 'package:foodkie/presentation/common_widgets/search_bar.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _isLoading = true;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  String _searchQuery = '';

  // Filter options
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Active', 'Completed', 'Cancelled'];

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
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);

        // Use the stream to get all orders for this waiter
        orderProvider.getWaiterOrdersStream(user.id)?.listen(
              (orders) {
            if (mounted) {
              setState(() {
                _orders = orders;
                _applyFilters();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User not found'),
              backgroundColor: Colors.red,
            ),
          );
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

  void _applyFilters() {
    List<Order> filtered = _orders;

    // Apply status filter
    switch (_selectedFilter) {
      case 'Active':
        filtered = filtered.where((order) =>
        order.status == OrderStatus.pending ||
            order.status == OrderStatus.accepted ||
            order.status == OrderStatus.preparing ||
            order.status == OrderStatus.ready
        ).toList();
        break;
      case 'Completed':
        filtered = filtered.where((order) => order.status == OrderStatus.served).toList();
        break;
      case 'Cancelled':
        filtered = filtered.where((order) => order.status == OrderStatus.cancelled).toList();
        break;
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        // Search by order ID
        if (order.id.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return true;
        }

        // Search by table ID
        if (order.tableId.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return true;
        }

        return false;
      }).toList();
    }

    // Sort orders by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredOrders = filtered;
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order History',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Search orders...',
              onSearch: _handleSearch,
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _applyFilters();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryColor : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Order list
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingWidget())
                : _filteredOrders.isEmpty
                ? EmptyStateWidget(
              message: 'No orders found',
              icon: Icons.receipt_long,
              actionLabel: 'Refresh',
              onAction: _loadOrders,
            )
                : RefreshIndicator(
              onRefresh: _loadOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
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
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}