// presentation/screens/waiter/order_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;

  const OrderConfirmationScreen({
    Key? key,
    required this.orderId,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _isLoading = true;
  Order? _order;
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
      final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);

      // Get order details
      final order = await orderProvider.getOrderById(widget.orderId);
      if (order != null) {
        setState(() {
          _order = order;
        });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(
          title: 'Order Confirmation',
          showBackButton: false,
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
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteConstants.waiterHome,
                        (route) => false,
                  );
                },
              ),
            ],
          ),
        )
            : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    // Success animation
    Lottie.asset(
    AssetsConstants.successAnimationPath,
    width: 200,
    height: 200,
    repeat: false,
    ),

    // Success text
    Text(
    'Order Placed Successfully!',
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
    fontWeight: FontWeight.bold,
    color: AppTheme.primaryColor,
    ),
    textAlign: TextAlign.center,
    ),

    const SizedBox(height: 8),

    // Order ID
    Text(
    'Order #${_order!.id.substring(0, 6).toUpperCase()}',
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.w500,
    ),
    ),

    const SizedBox(height: 32),

    // Order summary
    _buildOrderSummary(),

    const SizedBox(height: 32),

    // Order items
    _buildOrderItems(),

    const SizedBox(height: 32),

    // Action buttons
    Row(
    children: [
    Expanded(
    child: CustomButton(
    text: 'Order Details',
    onPressed: () {
    Navigator.pushReplacementNamed(
    context,
    RouteConstants.waiterOrderDetail,
    arguments: _order!.id,
    );
    },
      isOutlined: true,
    ),
    ),
      const SizedBox(width: 16),
      Expanded(
        child: CustomButton(
          text: 'Back to Home',
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.waiterHome,
                  (route) => false,
            );
          },
        ),
      ),
    ],
    ),
    ],
    ),
        ),
    );
  }

  Widget _buildOrderSummary() {
    // Try to get the table information
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final table = tableProvider.tables.firstWhere(
          (table) => table.id == _order!.tableId,
      orElse: () => throw Exception('Table not found'),
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Table info
            Row(
              children: [
                Icon(
                  Icons.table_restaurant,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Table ${table.number} (${table.capacity} seats)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Order info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:'),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _order!.status.name,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items:'),
                Text(
                  '${_order!.items.length}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total:'),
                Text(
                  NumberFormatter.formatCurrency(_order!.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _order!.items.map((item) {
                final foodItem = _foodItemsMap[item.foodItemId];
                if (foodItem == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item quantity
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodItem.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.notes != null && item.notes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Note: ${item.notes}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Item price
                      Text(
                        NumberFormatter.formatCurrency(foodItem.price * item.quantity),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        if (_order!.notes != null && _order!.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Order Notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
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
      ],
    );
  }
}