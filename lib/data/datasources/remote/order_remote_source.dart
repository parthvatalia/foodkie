// data/datasources/remote/order_remote_source.dart
import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/constants/error_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/data/models/order_item_model.dart';
import 'package:foodkie/core/utils/firebase_utils.dart';

class OrderRemoteSource {
  final cf.FirebaseFirestore _firestore = cf.FirebaseFirestore.instance;
  final String _orderCollection = AppConstants.ordersCollection;
  final String _orderItemCollection = AppConstants.orderItemsCollection;

  // Create a new order
  Future<Order> createOrder({
    required String tableId,
    required String waiterId,
    required List<OrderItem> items,
    String? notes,
  }) async {
    try {
      // Verify table exists
      final tableDoc = await _firestore
          .collection(AppConstants.tablesCollection)
          .doc(tableId)
          .get();

      if (!tableDoc.exists) {
        throw Exception(ErrorConstants.tableNotFound);
      }

      // Check table availability
      final tableStatus = TableStatusExtension.fromString(tableDoc.data()!['status'] as String);
      if (tableStatus != TableStatus.available) {
        throw Exception(ErrorConstants.tableNotAvailable);
      }

      // Verify waiter exists
      final waiterDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(waiterId)
          .get();

      if (!waiterDoc.exists) {
        throw Exception('Waiter not found');
      }

      // Verify all food items exist and are available
      for (var item in items) {
        final foodItemDoc = await _firestore
            .collection(AppConstants.foodItemsCollection)
            .doc(item.foodItemId)
            .get();

        if (!foodItemDoc.exists) {
          throw Exception('${item.foodItemId}: ${ErrorConstants.foodItemNotFound}');
        }

        final available = foodItemDoc.data()!['available'] as bool;
        if (!available) {
          throw Exception('${foodItemDoc.data()!['name']}: ${ErrorConstants.itemNotAvailable}');
        }
      }

      // Calculate total amount
      double totalAmount = 0;
      for (var item in items) {
        final foodItemDoc = await _firestore
            .collection(AppConstants.foodItemsCollection)
            .doc(item.foodItemId)
            .get();

        final price = (foodItemDoc.data()!['price'] as num).toDouble();
        totalAmount += price * item.quantity;
      }

      // Create order with transaction
      final orderId = FirebaseUtils.generateId();
      final now = DateTime.now();

      return await _firestore.runTransaction<Order>((transaction) async {
        // Create the order
        final order = Order(
          id: orderId,
          tableId: tableId,
          waiterId: waiterId,
          status: OrderStatus.pending,
          notes: notes,
          totalAmount: totalAmount,
          createdAt: now,
          updatedAt: now,
          items: items,
        );

        // Set order document
        transaction.set(
          _firestore.collection(_orderCollection).doc(orderId),
          order.toJson(excludeItems: true), // Exclude items as they'll be stored separately
        );

        // Set order items
        for (var item in items) {
          final orderItem = item.copyWith(
            id: FirebaseUtils.generateId(),
            orderId: orderId,
            createdAt: now,
            updatedAt: now,
          );

          transaction.set(
            _firestore.collection(_orderItemCollection).doc(orderItem.id),
            orderItem.toJson(),
          );
        }

        // Update table status to occupied
        transaction.update(
          _firestore.collection(AppConstants.tablesCollection).doc(tableId),
          {'status': TableStatus.occupied.value, 'updated_at': cf.Timestamp.fromDate(now)},
        );

        return order;
      });
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToCreate);
    }
  }

  // Get order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final orderDoc = await _firestore
          .collection(_orderCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        return null;
      }

      // Get order items
      final orderItemsSnapshot = await _firestore
          .collection(_orderItemCollection)
          .where('order_id', isEqualTo: orderId)
          .get();

      final items = orderItemsSnapshot.docs
          .map((doc) => OrderItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Create order with items
      return Order.fromJson(
        orderDoc.data() as Map<String, dynamic>,
        items: items,
      );
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Get orders for kitchen
  Stream<List<Order>> getOrdersForKitchen() {
    return _firestore
        .collection(_orderCollection)
        .where('status', whereIn: [
      OrderStatus.pending.value,
      OrderStatus.accepted.value,
      OrderStatus.preparing.value,
    ])
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap(_ordersWithItems);
  }

  // Get ready orders for kitchen
  Stream<List<Order>> getReadyOrdersForKitchen() {
    return _firestore
        .collection(_orderCollection)
        .where('status', isEqualTo: OrderStatus.ready.value)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .asyncMap(_ordersWithItems);
  }

  // Get orders by waiter
  Stream<List<Order>> getOrdersByWaiter(String waiterId) {
    return _firestore
        .collection(_orderCollection)
        .where('waiter_id', isEqualTo: waiterId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap(_ordersWithItems);
  }

  // Get active orders by waiter
  Stream<List<Order>> getActiveOrdersByWaiter(String waiterId) {
    return _firestore
        .collection(_orderCollection)
        .where('waiter_id', isEqualTo: waiterId)
        .where('status', whereIn: [
      OrderStatus.pending.value,
      OrderStatus.accepted.value,
      OrderStatus.preparing.value,
      OrderStatus.ready.value,
    ])
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap(_ordersWithItems);
  }

  // Get orders by table
  Stream<List<Order>> getOrdersByTable(String tableId) {
    return _firestore
        .collection(_orderCollection)
        .where('table_id', isEqualTo: tableId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap(_ordersWithItems);
  }

  // Get active order by table
  Future<Order?> getActiveOrderByTable(String tableId) async {
    try {
      final ordersSnapshot = await _firestore
          .collection(_orderCollection)
          .where('table_id', isEqualTo: tableId)
          .where('status', whereIn: [
        OrderStatus.pending.value,
        OrderStatus.accepted.value,
        OrderStatus.preparing.value,
        OrderStatus.ready.value,
      ])
          .limit(1)
          .get();

      if (ordersSnapshot.docs.isEmpty) {
        return null;
      }

      final orderDoc = ordersSnapshot.docs.first;

      // Get order items
      final orderItemsSnapshot = await _firestore
          .collection(_orderItemCollection)
          .where('order_id', isEqualTo: orderDoc.id)
          .get();

      final items = orderItemsSnapshot.docs
          .map((doc) => OrderItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Create order with items
      return Order.fromJson(
        orderDoc.data() as Map<String, dynamic>,
        items: items,
      );
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Get order history
  Future<List<Order>> getOrderHistory({int limit = 50}) async {
    try {
      final ordersSnapshot = await _firestore
          .collection(_orderCollection)
          .where('status', whereIn: [
        OrderStatus.served.value,
        OrderStatus.cancelled.value,
      ])
          .orderBy('created_at', descending: true)
          .limit(limit)
          .get();

      final orders = await Future.wait(
        ordersSnapshot.docs.map((doc) async {
          final orderId = doc.id;

          // Get order items
          final orderItemsSnapshot = await _firestore
              .collection(_orderItemCollection)
              .where('order_id', isEqualTo: orderId)
              .get();

          final items = orderItemsSnapshot.docs
              .map((doc) => OrderItem.fromJson(doc.data() as Map<String, dynamic>))
              .toList();

          // Create order with items
          return Order.fromJson(
            doc.data() as Map<String, dynamic>,
            items: items,
          );
        }),
      );

      return orders;
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Update order status
  Future<Order> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    try {
      // Check if order exists
      final orderDoc = await _firestore
          .collection(_orderCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception(ErrorConstants.orderNotFound);
      }

      final currentOrder = Order.fromJson(orderDoc.data() as Map<String, dynamic>);
      final currentStatus = currentOrder.status;

      // Validate status transitions
      if (!_isValidStatusTransition(currentStatus, status)) {
        throw Exception('Invalid status transition from ${currentStatus.name} to ${status.name}');
      }

      final now = DateTime.now();

      await _firestore.runTransaction((transaction) async {
        // Update order status
        transaction.update(
          _firestore.collection(_orderCollection).doc(orderId),
          {
            'status': status.value,
            'updated_at': cf.Timestamp.fromDate(now),
          },
        );

        // If status is served or cancelled, update table status to available
        if (status == OrderStatus.served || status == OrderStatus.cancelled) {
          transaction.update(
            _firestore.collection(AppConstants.tablesCollection).doc(currentOrder.tableId),
            {
              'status': TableStatus.available.value,
              'updated_at': cf.Timestamp.fromDate(now),
            },
          );
        }
      });

      // Get updated order with items
      return (await getOrderById(orderId))!;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Add item to existing order
  Future<Order> addItemToOrder({
    required String orderId,
    required String foodItemId,
    required int quantity,
    String? notes,
  }) async {
    try {
      // Check if order exists
      final orderDoc = await _firestore
          .collection(_orderCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception(ErrorConstants.orderNotFound);
      }

      // Check if order is in a valid state to add items
      final currentOrder = Order.fromJson(orderDoc.data() as Map<String, dynamic>);
      if (currentOrder.status != OrderStatus.pending &&
          currentOrder.status != OrderStatus.accepted) {
        throw Exception('Cannot add items to an order that is ${currentOrder.status.name}');
      }

      // Check if food item exists and is available
      final foodItemDoc = await _firestore
          .collection(AppConstants.foodItemsCollection)
          .doc(foodItemId)
          .get();

      if (!foodItemDoc.exists) {
        throw Exception(ErrorConstants.foodItemNotFound);
      }

      final available = foodItemDoc.data()!['available'] as bool;
      if (!available) {
        throw Exception('${foodItemDoc.data()!['name']}: ${ErrorConstants.itemNotAvailable}');
      }

      // Get price for total calculation
      final price = (foodItemDoc.data()!['price'] as num).toDouble();

      // Check if item already exists in order
      final orderItemsSnapshot = await _firestore
          .collection(_orderItemCollection)
          .where('order_id', isEqualTo: orderId)
          .where('food_item_id', isEqualTo: foodItemId)
          .get();

      final now = DateTime.now();

      await _firestore.runTransaction((transaction) async {
        if (orderItemsSnapshot.docs.isNotEmpty) {
          // Update existing item quantity
          final existingItem = orderItemsSnapshot.docs.first;
          final currentQuantity = existingItem.data()['quantity'] as int;

          transaction.update(
            _firestore.collection(_orderItemCollection).doc(existingItem.id),
            {
              'quantity': currentQuantity + quantity,
              'notes': notes ?? existingItem.data()['notes'],
              'updated_at': cf.Timestamp.fromDate(now),
            },
          );
        } else {
          // Create new order item
          final orderItem = OrderItem(
            id: FirebaseUtils.generateId(),
            orderId: orderId,
            foodItemId: foodItemId,
            quantity: quantity,
            notes: notes,
            status: OrderStatus.pending,
            createdAt: now,
            updatedAt: now,
          );

          transaction.set(
            _firestore.collection(_orderItemCollection).doc(orderItem.id),
            orderItem.toJson(),
          );
        }

        // Update order total amount and timestamp
        transaction.update(
          _firestore.collection(_orderCollection).doc(orderId),
          {
            'total_amount': cf.FieldValue.increment(price * quantity),
            'updated_at': cf.Timestamp.fromDate(now),
          },
        );
      });

      // Get updated order with items
      return (await getOrderById(orderId))!;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Remove item from order
  Future<Order> removeItemFromOrder({
    required String orderId,
    required String orderItemId,
  }) async {
    try {
      // Check if order exists
      final orderDoc = await _firestore
          .collection(_orderCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception(ErrorConstants.orderNotFound);
      }

      // Check if order is in a valid state to remove items
      final currentOrder = Order.fromJson(orderDoc.data() as Map<String, dynamic>);
      if (currentOrder.status != OrderStatus.pending &&
          currentOrder.status != OrderStatus.accepted) {
        throw Exception('Cannot remove items from an order that is ${currentOrder.status.name}');
      }

      // Check if order item exists
      final orderItemDoc = await _firestore
          .collection(_orderItemCollection)
          .doc(orderItemId)
          .get();

      if (!orderItemDoc.exists) {
        throw Exception('Order item not found');
      }

      // Verify item belongs to this order
      final itemOrderId = orderItemDoc.data()!['order_id'] as String;
      if (itemOrderId != orderId) {
        throw Exception('Item does not belong to this order');
      }

      // Get food item price for total calculation
      final foodItemId = orderItemDoc.data()!['food_item_id'] as String;
      final quantity = orderItemDoc.data()!['quantity'] as int;

      final foodItemDoc = await _firestore
          .collection(AppConstants.foodItemsCollection)
          .doc(foodItemId)
          .get();

      if (!foodItemDoc.exists) {
        throw Exception(ErrorConstants.foodItemNotFound);
      }

      final price = (foodItemDoc.data()!['price'] as num).toDouble();
      final now = DateTime.now();

      await _firestore.runTransaction((transaction) async {
        // Delete order item
        transaction.delete(
            _firestore.collection(_orderItemCollection).doc(orderItemId)
        );

        // Update order total amount and timestamp
        transaction.update(
          _firestore.collection(_orderCollection).doc(orderId),
          {
            'total_amount': cf.FieldValue.increment(-(price * quantity)),
            'updated_at': cf.Timestamp.fromDate(now),
          },
        );
      });

      // Get updated order with items
      return (await getOrderById(orderId))!;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Update item quantity in order
  Future<Order> updateItemQuantity({
    required String orderId,
    required String orderItemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        throw Exception(ErrorConstants.invalidQuantity);
      }

      // Check if order exists
      final orderDoc = await _firestore
          .collection(_orderCollection)
          .doc(orderId)
          .get();

      if (!orderDoc.exists) {
        throw Exception(ErrorConstants.orderNotFound);
      }

      // Check if order is in a valid state to update items
      final currentOrder = Order.fromJson(orderDoc.data() as Map<String, dynamic>);
      if (currentOrder.status != OrderStatus.pending &&
          currentOrder.status != OrderStatus.accepted) {
        throw Exception('Cannot update items in an order that is ${currentOrder.status.name}');
      }

      // Check if order item exists
      final orderItemDoc = await _firestore
          .collection(_orderItemCollection)
          .doc(orderItemId)
          .get();

      if (!orderItemDoc.exists) {
        throw Exception('Order item not found');
      }

      // Verify item belongs to this order
      final itemOrderId = orderItemDoc.data()!['order_id'] as String;
      if (itemOrderId != orderId) {
        throw Exception('Item does not belong to this order');
      }

      // Get food item price for total calculation
      final foodItemId = orderItemDoc.data()!['food_item_id'] as String;
      final currentQuantity = orderItemDoc.data()!['quantity'] as int;

      final foodItemDoc = await _firestore
          .collection(AppConstants.foodItemsCollection)
          .doc(foodItemId)
          .get();

      if (!foodItemDoc.exists) {
        throw Exception(ErrorConstants.foodItemNotFound);
      }

      final price = (foodItemDoc.data()!['price'] as num).toDouble();
      final quantityDifference = quantity - currentQuantity;
      final now = DateTime.now();

      await _firestore.runTransaction((transaction) async {
        // Update item quantity
        transaction.update(
          _firestore.collection(_orderItemCollection).doc(orderItemId),
          {
            'quantity': quantity,
            'updated_at': cf.Timestamp.fromDate(now),
          },
        );

        // Update order total amount and timestamp
        transaction.update(
          _firestore.collection(_orderCollection).doc(orderId),
          {
            'total_amount': cf.FieldValue.increment(price * quantityDifference),
            'updated_at': cf.Timestamp.fromDate(now),
          },
        );
      });

      // Get updated order with items
      return (await getOrderById(orderId))!;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Helper method to fetch orders with items
  Future<List<Order>> _ordersWithItems(cf.QuerySnapshot snapshot) async {
    return await Future.wait(
      snapshot.docs.map((doc) async {
        final orderId = doc.id;

        // Get order items
        final orderItemsSnapshot = await _firestore
            .collection(_orderItemCollection)
            .where('order_id', isEqualTo: orderId)
            .get();

        final items = orderItemsSnapshot.docs
            .map((doc) => OrderItem.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        // Create order with items
        return Order.fromJson(
          doc.data() as Map<String, dynamic>,
          items: items,
        );
      }),
    );
  }

  // Helper method to validate status transitions
  bool _isValidStatusTransition(OrderStatus from, OrderStatus to) {
    switch (from) {
      case OrderStatus.pending:
        return to == OrderStatus.accepted || to == OrderStatus.cancelled;
      case OrderStatus.accepted:
        return to == OrderStatus.preparing || to == OrderStatus.cancelled;
      case OrderStatus.preparing:
        return to == OrderStatus.ready || to == OrderStatus.cancelled;
      case OrderStatus.ready:
        return to == OrderStatus.served || to == OrderStatus.cancelled;
      case OrderStatus.served:
      case OrderStatus.cancelled:
        return false; // Terminal states
    }
  }
}