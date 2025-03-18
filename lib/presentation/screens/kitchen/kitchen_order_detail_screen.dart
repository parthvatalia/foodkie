// presentation/screens/kitchen/kitchen_order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/date_formatter.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/loading_widget.dart';
import 'package:foodkie/presentation/common_widgets/status_badge.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:lottie/lottie.dart';
import 'package:foodkie/core/constants/assets_constants.dart';
import 'package:foodkie/core/utils/toast_utils.dart';

class KitchenOrderDetailScreen extends StatefulWidget {
  final Order order;

  const KitchenOrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<KitchenOrderDetailScreen> createState() => _KitchenOrderDetailScreenState();
}

class _KitchenOrderDetailScreenState extends State<KitchenOrderDetailScreen> {
  Order? _currentOrder;
  bool _isLoading = false;
  Map<String, FoodItem> _foodItems = {};

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _loadFoodItems();
    _refreshOrder();
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      _isLoading = true;
    });

    final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);

    // Load food items for all order items
    for (final item in widget.order.items) {
      final foodItem = await foodItemProvider.getFoodItemById(item.foodItemId);
      if (foodItem != null && mounted) {
        setState(() {
          _foodItems[item.foodItemId] = foodItem;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final updatedOrder = await orderProvider.getOrderById(_currentOrder!.id);

    if (updatedOrder != null && mounted) {
      setState(() {
        _currentOrder = updatedOrder;
      });
    }
  }

  Future<void> _acceptOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.acceptOrder(_currentOrder!.id);
      await _refreshOrder();

      if (mounted) {
        ToastUtils.showSuccessToast('Order accepted successfully');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast('Failed to accept order: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startPreparing() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.startPreparingOrder(_currentOrder!.id);
      await _refreshOrder();

      if (mounted) {
        ToastUtils.showSuccessToast('Order preparation started');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast('Failed to start preparation: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsReady() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.markOrderAsReady(_currentOrder!.id);
      await _refreshOrder();

      if (mounted) {
        ToastUtils.showSuccessToast('Order marked as ready');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showErrorToast('Failed to mark order as ready: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelOrder() async {
    final result = await ConfirmationDialog.show(
      context: context,
      title: 'Cancel Order',
      message: 'Are you sure you want to cancel this order? This action cannot be undone.',
      confirmLabel: 'Cancel Order',
      cancelLabel: 'Keep Order',
      isDestructive: true,
      onConfirm: () {},
    );

    if (result == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final orderProvider = Provider.of<OrderProvider>(context, listen: false);
        await orderProvider.cancelOrder(_currentOrder!.id);
        await _refreshOrder();

        if (mounted) {
          ToastUtils.showSuccessToast('Order cancelled successfully');
        }
      } catch (e) {
        if (mounted) {
          ToastUtils.showErrorToast('Failed to cancel order: ${e.toString()}');
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentOrder == null) {
      return const Scaffold(
        body: Center(
          child: Text('Order not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_currentOrder!.id.substring(0, 6).toUpperCase()}'),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Processing...')
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status
            _buildOrderStatus(),

            const SizedBox(height: 24),

            // Order Info
            _buildOrderInfo(),

            const SizedBox(height: 24),

            // Order Items
            _buildOrderItems(),

            const SizedBox(height: 24),

            // Notes
            if (_currentOrder!.notes != null && _currentOrder!.notes!.isNotEmpty)
              _buildNotes(),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusItem(
                  status: OrderStatus.pending,
                  currentStatus: _currentOrder!.status,
                  label: 'Pending',
                  icon: Icons.schedule,
                ),

                _buildStatusArrow(),

                _buildStatusItem(
                  status: OrderStatus.accepted,
                  currentStatus: _currentOrder!.status,
                  label: 'Accepted',
                  icon: Icons.check_circle,
                ),

                _buildStatusArrow(),

                _buildStatusItem(
                  status: OrderStatus.preparing,
                  currentStatus: _currentOrder!.status,
                  label: 'Preparing',
                  icon: Icons.restaurant,
                ),

                _buildStatusArrow(),

                _buildStatusItem(
                  status: OrderStatus.ready,
                  currentStatus: _currentOrder!.status,
                  label: 'Ready',
                  icon: Icons.done_all,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem({
    required OrderStatus status,
    required OrderStatus currentStatus,
    required String label,
    required IconData icon,
  }) {
    final isActive = currentStatus == status;
    final isPassed = currentStatus.index > status.index;
    final color = isActive ? AppTheme.primaryColor : (isPassed ? AppTheme.successColor : Colors.grey);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusArrow() {
    return const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: Colors.grey,
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Order Date',
                    value: DateFormatter.formatDateTime(_currentOrder!.createdAt),
                    icon: Icons.calendar_today,
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    label: 'Table',
                    value: 'Table ${_currentOrder!.tableId}',
                    icon: Icons.table_restaurant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Order Status',
                    value: _getStatusText(_currentOrder!.status),
                    icon: Icons.info_outline,
                  ),
                ),

                Expanded(
                  child: _buildInfoItem(
                    label: 'Total',
                    value: NumberFormatter.formatCurrency(_currentOrder!.totalAmount),
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),

        const SizedBox(height: 4),

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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentOrder!.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _currentOrder!.items[index];
                final foodItem = _foodItems[item.foodItemId];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'x${item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    foodItem?.name ?? 'Unknown Item',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: item.notes != null && item.notes!.isNotEmpty
                      ? Text(
                    'Note: ${item.notes}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  )
                      : null,
                  trailing: foodItem != null
                      ? Text(
                    NumberFormatter.formatCurrency(foodItem.price * item.quantity),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                );
              },
            ),

            const Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  NumberFormatter.formatCurrency(_currentOrder!.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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

  Widget _buildNotes() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Notes',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentOrder!.notes!,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    // Order already completed or cancelled
    if (_currentOrder!.isServed || _currentOrder!.isCancelled) {
      return Center(
        child: Column(
          children: [
            Lottie.asset(
              _currentOrder!.isServed
                  ? AssetsConstants.successAnimationPath
                  : AssetsConstants.errorAnimationPath,
              width: 120,
              height: 120,
            ),

            const SizedBox(height: 16),

            Text(
              _currentOrder!.isServed
                  ? 'This order has been served'
                  : 'This order has been cancelled',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _currentOrder!.isServed ? AppTheme.successColor : AppTheme.errorColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentOrder!.isPending) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Accept Order',
              onPressed: _acceptOrder,
              icon: Icons.check_circle,
              color: AppTheme.successColor,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: CustomButton(
              text: 'Cancel Order',
              onPressed: _cancelOrder,
              icon: Icons.cancel,
              color: AppTheme.errorColor,
              isOutlined: true,
            ),
          ),
        ],
      );
    } else if (_currentOrder!.isAccepted) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Start Preparing',
              onPressed: _startPreparing,
              icon: Icons.restaurant,
              color: AppTheme.warningColor,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: CustomButton(
              text: 'Cancel Order',
              onPressed: _cancelOrder,
              icon: Icons.cancel,
              color: AppTheme.errorColor,
              isOutlined: true,
            ),
          ),
        ],
      );
    } else if (_currentOrder!.isPreparing) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Mark as Ready',
              onPressed: _markAsReady,
              icon: Icons.done_all,
              color: AppTheme.infoColor,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: CustomButton(
              text: 'Cancel Order',
              onPressed: _cancelOrder,
              icon: Icons.cancel,
              color: AppTheme.errorColor,
              isOutlined: true,
            ),
          ),
        ],
      );
    } else if (_currentOrder!.isReady) {
      return Center(
        child: Column(
          children: [
            StatusBadge(
              text: 'Ready for Pickup',
              color: AppTheme.successColor,
              fontSize: 14,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),

            const SizedBox(height: 16),

            const Text(
              'This order is ready for the waiter to serve',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getStatusText(OrderStatus status) {
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
}