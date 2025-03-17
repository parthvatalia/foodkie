// data/repositories/order_repository_impl.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/datasources/remote/order_remote_source.dart';
import 'package:foodkie/data/models/order_item_model.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteSource _remoteSource;

  OrderRepositoryImpl(this._remoteSource);

  @override
  Future<Order> createOrder({
    required String tableId,
    required String waiterId,
    required List<OrderItem> items,
    String? notes,
  }) async {
    try {
      return await _remoteSource.createOrder(
        tableId: tableId,
        waiterId: waiterId,
        items: items,
        notes: notes,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      return await _remoteSource.getOrderById(orderId);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Stream<List<Order>> getOrdersForKitchen() {
    return _remoteSource.getOrdersForKitchen();
  }

  @override
  Stream<List<Order>> getReadyOrdersForKitchen() {
    return _remoteSource.getReadyOrdersForKitchen();
  }

  @override
  Stream<List<Order>> getOrdersByWaiter(String waiterId) {
    return _remoteSource.getOrdersByWaiter(waiterId);
  }

  @override
  Stream<List<Order>> getActiveOrdersByWaiter(String waiterId) {
    return _remoteSource.getActiveOrdersByWaiter(waiterId);
  }

  @override
  Stream<List<Order>> getOrdersByTable(String tableId) {
    return _remoteSource.getOrdersByTable(tableId);
  }

  @override
  Future<Order?> getActiveOrderByTable(String tableId) async {
    try {
      return await _remoteSource.getActiveOrderByTable(tableId);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<Order>> getOrderHistory({int limit = 50}) async {
    try {
      return await _remoteSource.getOrderHistory(limit: limit);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      return await _remoteSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> addItemToOrder({
    required String orderId,
    required String foodItemId,
    required int quantity,
    String? notes,
  }) async {
    try {
      return await _remoteSource.addItemToOrder(
        orderId: orderId,
        foodItemId: foodItemId,
        quantity: quantity,
        notes: notes,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> removeItemFromOrder({
    required String orderId,
    required String orderItemId,
  }) async {
    try {
      return await _remoteSource.removeItemFromOrder(
        orderId: orderId,
        orderItemId: orderItemId,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> updateItemQuantity({
    required String orderId,
    required String orderItemId,
    required int quantity,
  }) async {
    try {
      return await _remoteSource.updateItemQuantity(
        orderId: orderId,
        orderItemId: orderItemId,
        quantity: quantity,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> acceptOrder(String orderId) async {
    try {
      return await _remoteSource.updateOrderStatus(
        orderId: orderId,
        status: OrderStatus.accepted,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> startPreparingOrder(String orderId) async {
    try {
      return await _remoteSource.updateOrderStatus(
        orderId: orderId,
        status: OrderStatus.preparing,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> markOrderAsReady(String orderId) async {
    try {
      return await _remoteSource.updateOrderStatus(
        orderId: orderId,
        status: OrderStatus.ready,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> markOrderAsServed(String orderId) async {
    try {
      return await _remoteSource.updateOrderStatus(
        orderId: orderId,
        status: OrderStatus.served,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Order> cancelOrder(String orderId) async {
    try {
      return await _remoteSource.updateOrderStatus(
        orderId: orderId,
        status: OrderStatus.cancelled,
      );
    } catch (e) {
      throw e.toString();
    }
  }
}