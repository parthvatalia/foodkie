// presentation/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/data/models/order_item_model.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/usecases/order/accept_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/add_item_to_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/cancel_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/create_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_kitchen_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_order_history_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_ready_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_table_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/get_waiter_orders_usecase.dart';
import 'package:foodkie/domain/usecases/order/mark_order_ready_usecase.dart';
import 'package:foodkie/domain/usecases/order/mark_order_served_usecase.dart';
import 'package:foodkie/domain/usecases/order/remove_item_from_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/start_preparing_order_usecase.dart';
import 'package:foodkie/domain/usecases/order/update_item_quantity_usecase.dart';
import 'package:foodkie/domain/usecases/order/update_order_status_usecase.dart';

enum OrderProviderStatus {
  initial,
  loading,
  loaded,
  error,
}

class OrderProvider with ChangeNotifier {
  final CreateOrderUseCase? createOrderUseCase;
  final GetOrderUseCase? getOrderUseCase;
  final GetKitchenOrdersUseCase? getKitchenOrdersUseCase;
  final GetReadyOrdersUseCase? getReadyOrdersUseCase;
  final GetWaiterOrdersUseCase? getWaiterOrdersUseCase;
  final GetTableOrdersUseCase? getTableOrdersUseCase;
  final GetOrderHistoryUseCase? getOrderHistoryUseCase;
  final UpdateOrderStatusUseCase? updateOrderStatusUseCase;
  final AddItemToOrderUseCase? addItemToOrderUseCase;
  final RemoveItemFromOrderUseCase? removeItemFromOrderUseCase;
  final UpdateItemQuantityUseCase? updateItemQuantityUseCase;
  final AcceptOrderUseCase? acceptOrderUseCase;
  final StartPreparingOrderUseCase? startPreparingOrderUseCase;
  final MarkOrderReadyUseCase? markOrderReadyUseCase;
  final MarkOrderServedUseCase? markOrderServedUseCase;
  final CancelOrderUseCase? cancelOrderUseCase;

  OrderProvider({
    this.createOrderUseCase,
    this.getOrderUseCase,
    this.getKitchenOrdersUseCase,
    this.getReadyOrdersUseCase,
    this.getWaiterOrdersUseCase,
    this.getTableOrdersUseCase,
    this.getOrderHistoryUseCase,
    this.updateOrderStatusUseCase,
    this.addItemToOrderUseCase,
    this.removeItemFromOrderUseCase,
    this.updateItemQuantityUseCase,
    this.acceptOrderUseCase,
    this.startPreparingOrderUseCase,
    this.markOrderReadyUseCase,
    this.markOrderServedUseCase,
    this.cancelOrderUseCase,
  });

  List<Order> _orders = [];
  OrderProviderStatus _status = OrderProviderStatus.initial;
  String? _errorMessage;
  Order? _selectedOrder;
  String? _selectedTableId;
  String? _selectedWaiterId;
  List<OrderItem> _cart = [];

  // Getters
  List<Order> get orders => _orders;
  OrderProviderStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Order? get selectedOrder => _selectedOrder;
  String? get selectedTableId => _selectedTableId;
  String? get selectedWaiterId => _selectedWaiterId;
  List<OrderItem> get cart => _cart;
  bool get isLoading => _status == OrderProviderStatus.loading;
  bool get hasItemsInCart => _cart.isNotEmpty;
  double get cartTotal => _calculateCartTotal();

  // Get kitchen orders stream
  Stream<List<Order>>? getKitchenOrdersStream() {
    return getKitchenOrdersUseCase?.execute();
  }

  // Get ready orders stream
  Stream<List<Order>>? getReadyOrdersStream() {
    return getReadyOrdersUseCase?.execute();
  }

  // Get waiter orders stream
  Stream<List<Order>>? getWaiterOrdersStream(String waiterId) {
    _selectedWaiterId = waiterId;
    return getWaiterOrdersUseCase?.execute(waiterId);
  }

  // Get active waiter orders stream
  Stream<List<Order>>? getActiveWaiterOrdersStream(String waiterId) {
    _selectedWaiterId = waiterId;
    return getWaiterOrdersUseCase?.executeActiveOnly(waiterId);
  }

  // Get table orders stream
  Stream<List<Order>>? getTableOrdersStream(String tableId) {
    _selectedTableId = tableId;
    return getTableOrdersUseCase?.execute(tableId);
  }

  // Load kitchen orders
  Future<void> loadKitchenOrders() async {
    try {
      _setStatus(OrderProviderStatus.loading);

      // If we have a stream-based implementation
      if (getKitchenOrdersUseCase != null) {
        getKitchenOrdersUseCase!.execute().listen(
              (orders) {
            _orders = orders;
            _selectedOrder = orders.isNotEmpty ? orders.first : null;
            _setStatus(OrderProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(OrderProviderStatus.error);
        _setError('Kitchen orders use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load ready orders for kitchen
  Future<void> loadReadyOrders() async {
    try {
      _setStatus(OrderProviderStatus.loading);

      // If we have a stream-based implementation
      if (getReadyOrdersUseCase != null) {
        getReadyOrdersUseCase!.execute().listen(
              (orders) {
            _orders = orders;
            _selectedOrder = orders.isNotEmpty ? orders.first : null;
            _setStatus(OrderProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(OrderProviderStatus.error);
        _setError('Ready orders use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load waiter orders
  Future<void> loadWaiterOrders(String waiterId) async {
    try {
      _setStatus(OrderProviderStatus.loading);
      _selectedWaiterId = waiterId;

      // If we have a stream-based implementation
      if (getWaiterOrdersUseCase != null) {
        getWaiterOrdersUseCase!.execute(waiterId).listen(
              (orders) {
            _orders = orders;
            _selectedOrder = orders.isNotEmpty ? orders.first : null;
            _setStatus(OrderProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(OrderProviderStatus.error);
        _setError('Waiter orders use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load active waiter orders
  Future<void> loadActiveWaiterOrders(String waiterId) async {
    try {
      _setStatus(OrderProviderStatus.loading);
      _selectedWaiterId = waiterId;

      // If we have a stream-based implementation
      if (getWaiterOrdersUseCase != null) {
        getWaiterOrdersUseCase!.executeActiveOnly(waiterId).listen(
              (orders) {
            _orders = orders;
            _selectedOrder = orders.isNotEmpty ? orders.first : null;
            _setStatus(OrderProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(OrderProviderStatus.error);
        _setError('Active waiter orders use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load table orders
  Future<void> loadTableOrders(String tableId) async {
    try {
      _setStatus(OrderProviderStatus.loading);
      _selectedTableId = tableId;

      // If we have a stream-based implementation
      if (getTableOrdersUseCase != null) {
        getTableOrdersUseCase!.execute(tableId).listen(
              (orders) {
            _orders = orders;
            _selectedOrder = orders.isNotEmpty ? orders.first : null;
            _setStatus(OrderProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(OrderProviderStatus.error);
        _setError('Table orders use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get active order for table
  Future<Order?> getActiveOrderForTable(String tableId) async {
    try {
      _setStatus(OrderProviderStatus.loading);
      _selectedTableId = tableId;

      final order = await getTableOrdersUseCase?.getActiveOrder(tableId);

      _setStatus(OrderProviderStatus.loaded);
      return order;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Get order history
  Future<List<Order>> getOrderHistory({int limit = 50}) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      final history = await getOrderHistoryUseCase?.execute(limit: limit) ?? [];

      _setStatus(OrderProviderStatus.loaded);
      return history;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      _setStatus(OrderProviderStatus.loading);
      final order = await getOrderUseCase?.execute(orderId);

      if (order != null) {
        _selectedOrder = order;
      }

      _setStatus(OrderProviderStatus.loaded);
      return order;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Create an order
  Future<Order?> createOrder({
    required String tableId,
    required String waiterId,
    String? notes,
  }) async {
    try {
      if (_cart.isEmpty) {
        throw Exception('Cannot create an order with an empty cart');
      }

      _setStatus(OrderProviderStatus.loading);

      final order = await createOrderUseCase?.execute(
        tableId: tableId,
        waiterId: waiterId,
        items: _cart,
        notes: notes,
      );

      // Clear cart after successful order creation
      if (order != null) {
        clearCart();
      }

      _setStatus(OrderProviderStatus.loaded);
      return order;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await updateOrderStatusUseCase?.execute(
        orderId: orderId,
        status: status,
      );

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Accept order
  Future<bool> acceptOrder(String orderId) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await acceptOrderUseCase?.execute(orderId);

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Start preparing order
  Future<bool> startPreparingOrder(String orderId) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await startPreparingOrderUseCase?.execute(orderId);

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Mark order as ready
  Future<bool> markOrderAsReady(String orderId) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await markOrderReadyUseCase?.execute(orderId);

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Mark order as served
  Future<bool> markOrderAsServed(String orderId) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await markOrderServedUseCase?.execute(orderId);

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await cancelOrderUseCase?.execute(orderId);

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Add item to existing order
  Future<bool> addItemToOrder({
    required String orderId,
    required String foodItemId,
    required int quantity,
    String? notes,
  }) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await addItemToOrderUseCase?.execute(
        orderId: orderId,
        foodItemId: foodItemId,
        quantity: quantity,
        notes: notes,
      );

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Remove item from order
  Future<bool> removeItemFromOrder({
    required String orderId,
    required String orderItemId,
  }) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await removeItemFromOrderUseCase?.execute(
        orderId: orderId,
        orderItemId: orderItemId,
      );

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update item quantity in order
  Future<bool> updateItemQuantity({
    required String orderId,
    required String orderItemId,
    required int quantity,
  }) async {
    try {
      _setStatus(OrderProviderStatus.loading);

      await updateItemQuantityUseCase?.execute(
        orderId: orderId,
        orderItemId: orderItemId,
        quantity: quantity,
      );

      _setStatus(OrderProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Cart Management
  void addToCart(FoodItem foodItem, int quantity, {String? notes}) {
    // Check if item is already in cart
    final existingItemIndex = _cart.indexWhere((item) => item.foodItemId == foodItem.id);

    if (existingItemIndex >= 0) {
      // Update existing item quantity
      final existingItem = _cart[existingItemIndex];
      final updatedItem = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
        notes: notes ?? existingItem.notes,
      );

      _cart[existingItemIndex] = updatedItem;
    } else {
      // Add new item to cart
      final orderItem = OrderItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        orderId: '', // Will be set when order is created
        foodItemId: foodItem.id,
        quantity: quantity,
        notes: notes,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _cart.add(orderItem);
    }

    notifyListeners();
  }

  void removeFromCart(String foodItemId) {
    _cart.removeWhere((item) => item.foodItemId == foodItemId);
    notifyListeners();
  }

  void updateCartItemQuantity(String foodItemId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(foodItemId);
      return;
    }

    final itemIndex = _cart.indexWhere((item) => item.foodItemId == foodItemId);

    if (itemIndex >= 0) {
      final item = _cart[itemIndex];
      _cart[itemIndex] = item.copyWith(quantity: quantity);
      notifyListeners();
    }
  }

  void updateCartItemNotes(String foodItemId, String? notes) {
    final itemIndex = _cart.indexWhere((item) => item.foodItemId == foodItemId);

    if (itemIndex >= 0) {
      final item = _cart[itemIndex];
      _cart[itemIndex] = item.copyWith(notes: notes);
      notifyListeners();
    }
  }

  void clearCart() {
    _cart = [];
    notifyListeners();
  }

  // Calculate cart total amount
  double _calculateCartTotal() {
    // In a real implementation, this would fetch prices from the repository
    // For now, we'll just return a basic sum
    return _cart.fold(0, (total, item) => total + (item.quantity * 0)); // Price is missing here
  }

  // Set selected order
  void selectOrder(Order order) {
    _selectedOrder = order;
    notifyListeners();
  }

  // Set selected order by ID
  Future<void> selectOrderById(String id) async {
    final order = await getOrderById(id);
    if (order != null) {
      _selectedOrder = order;
      notifyListeners();
    }
  }

  // Set table for ordering
  void setSelectedTable(String tableId) {
    _selectedTableId = tableId;
    notifyListeners();
  }

  // Helper Methods
  void _setStatus(OrderProviderStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = OrderProviderStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}