// domain/repositories/order_repository.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/order_item_model.dart';
import 'package:foodkie/data/models/order_model.dart';

abstract class OrderRepository {
  Future<Order> createOrder({
    required String tableId,
    required String waiterId,
    required List<OrderItem> items,
    String? customerName,
    String? notes,
  });

  Future<Order?> getOrderById(String orderId);

  Stream<List<Order>> getOrdersForKitchen();

  Stream<List<Order>> getReadyOrdersForKitchen();

  Stream<List<Order>> getAllOrdersByTable(String tableId);

  Future<Map<String, dynamic>> getTableBillSummary(String tableId);

  Stream<List<Order>> getOrdersByWaiter(String waiterId);

  Stream<List<Order>> getActiveOrdersByWaiter(String waiterId);

  Stream<List<Order>> getOrdersByTable(String tableId);

  Future<Order?> getActiveOrderByTable(String tableId);

  Future<List<Order>> getOrderHistory({int limit = 50});

  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });

  Future<Order> addItemToOrder({
    required String orderId,
    required String foodItemId,
    required int quantity,
    String? notes,
  });

  Future<Order> removeItemFromOrder({
    required String orderId,
    required String orderItemId,
  });

  Future<Order> updateItemQuantity({
    required String orderId,
    required String orderItemId,
    required int quantity,
  });

  // Convenient methods for specific order status updates
  Future<Order> acceptOrder(String orderId);

  Future<Order> startPreparingOrder(String orderId);

  Future<Order> markOrderAsReady(String orderId);

  Future<Order> markOrderAsServed(String orderId);

  Future<Order> cancelOrder(String orderId);
}
