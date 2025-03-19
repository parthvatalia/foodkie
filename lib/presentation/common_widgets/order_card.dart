// presentation/common_widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/extensions/datetime_extantions.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/presentation/common_widgets/status_badge.dart';
import 'package:provider/provider.dart';

import '../../data/models/table_model.dart';
import '../providers/table_provider.dart';

class OrderCard extends StatefulWidget {
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
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  TableModel? _table;

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    try {
      final tableProvider = Provider.of<TableProvider>(context, listen: false);
      // Get order details

      // Get table info
      final table = await tableProvider.getTableById(widget.order.tableId);
      if (table != null) {
        setState(() {
          _table = table;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading order details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      delay: 0.2,
      child: GestureDetector(
        onTap: widget.onTap,
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
              if (widget.showDetails) _buildOrderDetails(context),

              // Order Actions
              if (widget.showActions) _buildOrderActions(context),
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
                'Order #${widget.order.id.substring(0, 6).toUpperCase()}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              // Order Time
              Text(
                widget.order.createdAt.formatRelative(),
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
                    'Table number: ${_table?.number.toString() ?? 0}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              // Items Count
              Text(
                '${widget.order.items.length} ${widget.order.items.length == 1 ? 'item' : 'items'}',
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
              StatusBadge(text: _getStatusText(), color: _getStatusColor()),

              // Total Amount
              Text(
                NumberFormatter.formatCurrency(widget.order.totalAmount),
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Items List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.order.items.length,
                itemBuilder: (context, index) {
                  final item = widget.order.items[index];
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
              if (widget.order.notes != null &&
                  widget.order.notes!.isNotEmpty) ...[
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
                    widget.order.notes!,
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
    if (widget.order.isServed || widget.order.isCancelled) {
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
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Accept Button
                  if (widget.order.isPending && widget.onAccept != null)
                    _buildActionButton(
                      context,
                      'Accept',
                      Icons.check_circle_outline,
                      AppTheme.successColor,
                      () => widget.onAccept!(widget.order.id),
                    ),

                  // Prepare Button
                  if (widget.order.isAccepted && widget.onPrepare != null)
                    _buildActionButton(
                      context,
                      'Prepare',
                      Icons.restaurant,
                      AppTheme.warningColor,
                      () => widget.onPrepare!(widget.order.id),
                    ),

                  // Ready Button
                  if (widget.order.isPreparing && widget.onReady != null)
                    _buildActionButton(
                      context,
                      'Ready',
                      Icons.done_all,
                      AppTheme.infoColor,
                      () => widget.onReady!(widget.order.id),
                    ),

                  // Serve Button
                  if (widget.order.isReady && widget.onServe != null)
                    _buildActionButton(
                      context,
                      'Serve',
                      Icons.room_service,
                      AppTheme.primaryColor,
                      () => widget.onServe!(widget.order.id),
                    ),

                  // Cancel Button
                  if (widget.order.isActive && widget.onCancel != null)
                    _buildActionButton(
                      context,
                      'Cancel',
                      Icons.cancel_outlined,
                      AppTheme.errorColor,
                      () => widget.onCancel!(widget.order.id),
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
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (widget.order.status) {
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
    switch (widget.order.status) {
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
