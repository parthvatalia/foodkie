// presentation/common_widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/extensions/datetime_extantions.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/presentation/common_widgets/status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool showActions;
  final Function(String)? onAccept;
  final Function(String)? onPrepare;
  final Function(String)? onReady;
  final Function(String)? onServe;
  final Function(String)? onCancel;

  const OrderCard({
    Key? key,
    required this.order,
    this.onTap,
    this.showDetails = false,
    this.showActions = false,
    this.onAccept,
    this.onPrepare,
    this.onReady,
    this.onServe,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: 0.2,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
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
              // Order Header
              _buildOrderHeader(context),

              // Order Details
              if (showDetails) _buildOrderDetails(context),

              // Order Actions
              if (showActions) _buildOrderActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID and Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order ID
              Text(
                'Order #${order.id.substring(0, 6).toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Order Time
              Text(
                order.createdAt.formatRelative(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightSubtextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Table and Items Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Table
              Row(
                children: [
                  const Icon(
                    Icons.table_restaurant,
                    size: 16,
                    color: AppTheme.lightSubtextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Table ${order.tableId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              // Items Count
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status and Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status Badge
              StatusBadge(
                text: _getStatusText(),
                color: _getStatusColor(),
              ),

              // Total Amount
              Text(
                NumberFormatter.formatCurrency(order.totalAmount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        const Divider(height: 1),

        // Order Items
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                'Order Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Items List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Item Quantity and Name
                        Expanded(
                          child: Row(
                            children: [
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
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.foodItemId,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Item Notes Indicator
                        if (item.notes != null && item.notes!.isNotEmpty)
                          const Icon(
                            Icons.comment,
                            size: 16,
                            color: AppTheme.infoColor,
                          ),
                      ],
                    ),
                  );
                },
              ),

              // Notes
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),

                // Section Title
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Notes Content
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderActions(BuildContext context) {
    // Only show actions for active orders
    if (order.isServed || order.isCancelled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Divider
        const Divider(height: 1),

        // Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title
              Text(
                'Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Accept Button
                  if (order.isPending && onAccept != null)
                    _buildActionButton(
                      context,
                      'Accept',
                      Icons.check_circle_outline,
                      AppTheme.successColor,
                          () => onAccept!(order.id),
                    ),

                  // Prepare Button
                  if (order.isAccepted && onPrepare != null)
                    _buildActionButton(
                      context,
                      'Prepare',
                      Icons.restaurant,
                      AppTheme.warningColor,
                          () => onPrepare!(order.id),
                    ),

                  // Ready Button
                  if (order.isPreparing && onReady != null)
                    _buildActionButton(
                      context,
                      'Ready',
                      Icons.done_all,
                      AppTheme.infoColor,
                          () => onReady!(order.id),
                    ),

                  // Serve Button
                  if (order.isReady && onServe != null)
                    _buildActionButton(
                      context,
                      'Serve',
                      Icons.room_service,
                      AppTheme.primaryColor,
                          () => onServe!(order.id),
                    ),

                  // Cancel Button
                  if (order.isActive && onCancel != null)
                    _buildActionButton(
                      context,
                      'Cancel',
                      Icons.cancel_outlined,
                      AppTheme.errorColor,
                          () => onCancel!(order.id),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      String label,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (order.status) {
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

  Color _getStatusColor() {
    switch (order.status) {
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
}