// data/models/order_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkie/core/enums/app_enums.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String foodItemId;
  final int quantity;
  final String? notes;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.foodItemId,
    required this.quantity,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      foodItemId: json['food_item_id'] as String,
      quantity: json['quantity'] as int,
      notes: json['notes'] as String?,
      status: OrderStatusExtension.fromString(json['status'] as String),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'food_item_id': foodItemId,
      'quantity': quantity,
      'notes': notes,
      'status': status.value,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? foodItemId,
    int? quantity,
    String? notes,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      foodItemId: foodItemId ?? this.foodItemId,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}