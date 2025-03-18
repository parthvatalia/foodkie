// presentation/screens/waiter/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/extensions/datetime_extantions.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  Order? _order;
  TableModel? _table;
  Map<String, FoodItem> _foodItemsMap = {};

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);

      // Get order details
      final order = await orderProvider.getOrderById(widget.orderId);
      if (order != null) {
        setState(() {
          _order = order;
        });

        // Get table info
        final table = await tableProvider.getTableById(order.tableId);
        if (table != null) {
          setState(() {
            _table = table;
          });
        }

        // Get food items
        for (final item in order.items) {
          final foodItem = await foodItemProvider.getFoodItemById(item.foodItemId);
          if (foodItem != null) {
            setState(() {
              _foodItemsMap[item.foodItemId] = foodItem;
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading order details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsServed() async {
    if (_order == null) return;

    // Show confirmation dialog
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: 'Mark as Served',
      message: 'Are you sure you want to mark this order as served?',
      confirmLabel: 'Yes, Mark as Served',
      cancelLabel: 'Cancel',
      onConfirm: () {},
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.markOrderAsServed(_order!.id);

      // Refresh the order details
      await _loadOrderDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as served'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _cancelOrder() async {
    if (_order == null) return;

    // Show confirmation dialog
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order? This action cannot be undone.',
      confirmLabel: 'Yes, Cancel Order',
      cancelLabel: 'No, Keep Order',
      isDestructive: true,
      onConfirm: () {},
    );

    if (confirm != true) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.cancelOrder(_order!.id);

      // Refresh the order details
      await _loadOrderDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Details',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: LoadingWidget())
          : _order == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Order not found'),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Go to Home',
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  RouteConstants.waiterHome,
                );
              },
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Order details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order header
                  _buildOrderHeader(),

                  const SizedBox(height: 24),

                  // Order items
                  _buildOrderItems(),

                  const SizedBox(height: 24),

                  // Order notes
                  if (_order!.notes != null && _order!.notes!.isNotEmpty)
                    _buildOrderNotes(),

                  // Add extra padding at bottom for the action buttons
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Action buttons
          if (_order!.isActive)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel Order',
                      onPressed: _isProcessing ? (){} : _cancelOrder,
                      isOutlined: true,
                      color: Colors.red,
                      textColor: Colors.red,
                      disabled: _isProcessing || _order!.isCancelled,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Mark as Served Button (only for ready orders)
                  Expanded(
                    child: CustomButton(
                      text: 'Mark as Served',
                      onPressed: _isProcessing || !_order!.isReady
                          ? (){}
                          : _markAsServed,
                      disabled: _isProcessing || !_order!.isReady,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${_order!.id.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                _buildStatusBadge(_order!.status),
              ],
            ),
            const Divider(height: 24),
            // Order details
            _buildOrderDetail('Table', _table != null ? 'Table ${_table!.number}' : 'Unknown'),
            const SizedBox(height: 8),
            _buildOrderDetail('Date', _order!.createdAt.formatDate()),
            const SizedBox(height: 8),
            _buildOrderDetail('Time', _order!.createdAt.formatTime()),
            const SizedBox(height: 8),
            _buildOrderDetail('Total', NumberFormatter.formatCurrency(_order!.totalAmount)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = Colors.blue;
        break;
      case OrderStatus.accepted:
        color = Colors.orange;
        break;
      case OrderStatus.preparing:
        color = Colors.amber;
        break;
      case OrderStatus.ready:
        color = Colors.green;
        break;
      case OrderStatus.served:
        color = Colors.purple;
        break;
      case OrderStatus.cancelled:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _order!.items[index];
              final foodItem = _foodItemsMap[item.foodItemId];

              if (foodItem == null) {
                return ListTile(
                  title: Text('Unknown Item'),
                  subtitle: Text('Item details not available'),
                );
              }

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'x${item.quantity}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  foodItem.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: item.notes != null && item.notes!.isNotEmpty
                    ? Text(
                  'Note: ${item.notes}',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                )
                    : null,
                trailing: Text(
                  NumberFormatter.formatCurrency(foodItem.price * item.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Notes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_order!.notes!),
          ),
        ),
      ],
    );
  }
}