// presentation/screens/waiter/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodkie/core/animations/fade_animation.dart';
import 'package:foodkie/core/constants/route_constants.dart';
import 'package:foodkie/core/theme/app_theme.dart';
import 'package:foodkie/core/utils/number_formatter.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/data/models/order_item_model.dart';
import 'package:foodkie/presentation/common_widgets/app_bar_widget.dart';
import 'package:foodkie/presentation/common_widgets/confirmation_dialog.dart';
import 'package:foodkie/presentation/common_widgets/custom_button.dart';
import 'package:foodkie/presentation/common_widgets/empty_state_widget.dart';
import 'package:foodkie/presentation/providers/auth_provider.dart';
import 'package:foodkie/presentation/providers/food_item_provider.dart';
import 'package:foodkie/presentation/providers/order_provider.dart';
import 'package:foodkie/presentation/providers/table_provider.dart';

import '../../../core/enums/app_enums.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _notesController = TextEditingController();
  bool _isLoading = false;
  Map<String, FoodItem> _foodItemsMap = {};

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final foodItemProvider = Provider.of<FoodItemProvider>(context, listen: false);

      // Get all food items in the cart
      final foodItemIds = orderProvider.cart.map((item) => item.foodItemId).toSet();

      for (final id in foodItemIds) {
        final foodItem = await foodItemProvider.getFoodItemById(id);
        if (foodItem != null) {
          setState(() {
            _foodItemsMap[id] = foodItem;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading food items: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeItem(OrderItem item) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.removeFromCart(item.foodItemId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateQuantity(OrderItem item, int quantity) {
    if (quantity <= 0) {
      // Show confirmation dialog before removing
      ConfirmationDialog.show(
        context: context,
        title: 'Remove Item',
        message: 'Are you sure you want to remove this item from the cart?',
        confirmLabel: 'Remove',
        cancelLabel: 'Cancel',
        onConfirm: () => _removeItem(item),
        isDestructive: true,
      );
      return;
    }

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.updateCartItemQuantity(item.foodItemId, quantity);
  }

  void _updateNotes(OrderItem item, String? notes) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.updateCartItemNotes(item.foodItemId, notes);
  }

  Future<void> _placeOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tableProvider = Provider.of<TableProvider>(context, listen: false);

    final selectedTableId = orderProvider.selectedTableId;
    final waiterId = authProvider.user?.id;

    if (selectedTableId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No table selected'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (waiterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (orderProvider.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create the order
      final order = await orderProvider.createOrder(
        tableId: selectedTableId,
        waiterId: waiterId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (order != null) {
        // Update table status
        await tableProvider.updateTableStatus(
          id: selectedTableId,
          status: TableStatus.occupied,
        );

        // Navigate to order confirmation
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.waiterOrderConfirmation,
                (route) => route.settings.name == RouteConstants.waiterHome,
            arguments: order.id,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to create order'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _calculateTotal() {
    double total = 0;

    for (final item in Provider.of<OrderProvider>(context).cart) {
      final foodItem = _foodItemsMap[item.foodItemId];
      if (foodItem != null) {
        total += foodItem.price * item.quantity;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final cart = orderProvider.cart;
    final tableProvider = Provider.of<TableProvider>(context);
    final selectedTableId = orderProvider.selectedTableId;

    // Try to get the selected table
    final selectedTable = selectedTableId != null
        ? tableProvider.tables.firstWhere(
          (table) => table.id == selectedTableId,
      orElse: () => throw Exception('Selected table not found'),
    )
        : null;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Order Cart',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
          ? EmptyStateWidget(
        message: 'Your cart is empty',
        icon: Icons.shopping_cart_outlined,
        actionLabel: 'Add Items',
        onAction: () {
          Navigator.pop(context);
        },
      )
          : Column(
        children: [
          // Table info
          if (selectedTable != null) ...[
            Container(
              color: AppTheme.primaryColor.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.table_restaurant,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Table ${selectedTable.number} (${selectedTable.capacity} seats)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Cart items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                final foodItem = _foodItemsMap[item.foodItemId];

                if (foodItem == null) {
                  return const SizedBox.shrink();
                }

                return FadeAnimation(
                  delay: 0.05 * (index + 1),
                  child: _buildCartItem(item, foodItem),
                );
              },
            ),
          ),

          // Order notes
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Order Notes (Optional)',
                hintText: 'Special instructions for the kitchen',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 2,
            ),
          ),

          // Order summary and Place Order button
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      NumberFormatter.formatCurrency(_calculateTotal()),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Place Order button
                CustomButton(
                  text: 'Place Order',
                  onPressed: _placeOrder,
                  isLoading: _isLoading,
                  width: double.infinity,
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(OrderItem item, FoodItem foodItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food item details
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: foodItem.imageUrl.isNotEmpty
                      ? Image.network(
                    foodItem.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Food details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        foodItem.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormatter.formatCurrency(foodItem.price),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Remove button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _removeItem(item),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quantity selector
            Row(
              children: [
                const Text(
                  'Quantity:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () => _updateQuantity(item, item.quantity - 1),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.remove, size: 16),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                InkWell(
                  onTap: () => _updateQuantity(item, item.quantity + 1),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.add, size: 16),
                  ),
                ),
                const Spacer(),
                // Item subtotal
                Text(
                  NumberFormatter.formatCurrency(foodItem.price * item.quantity),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Item notes
            TextField(
              controller: TextEditingController(text: item.notes),
              decoration: InputDecoration(
                labelText: 'Special Instructions',
                hintText: 'E.g., No onions, extra spicy',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              onChanged: (value) => _updateNotes(item, value),
            ),
          ],
        ),
      ),
    );
  }
}