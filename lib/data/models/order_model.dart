// data/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/order_item_model.dart';

class Order {
  final String id;
  final String tableId;
  final String waiterId;
  final String? customerName; // New field for customer name
  final OrderStatus status;
  final String? notes;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.tableId,
    required this.waiterId,
    this.customerName, // Added customer name parameter
    required this.status,
    this.notes,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json, {List<OrderItem>? items}) {
    return Order(
      id: json['id'] as String,
      tableId: json['table_id'] as String,
      waiterId: json['waiter_id'] as String,
      customerName: json['customer_name'] as String?, // Parse customer name
      status: OrderStatusExtension.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      items: items ?? [],
    );
  }

  Map<String, dynamic> toJson({bool excludeItems = false}) {
    final Map<String, dynamic> json = {
      'id': id,
      'table_id': tableId,
      'waiter_id': waiterId,
      'customer_name': customerName, // Include customer name in JSON
      'status': status.value,
      'notes': notes,
      'total_amount': totalAmount,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };

    if (!excludeItems) {
      json['items'] = items.map((item) => item.toJson()).toList();
    }

    return json;
  }

  Order copyWith({
    String? id,
    String? tableId,
    String? waiterId,
    String? customerName, // Added to copyWith
    OrderStatus? status,
    String? notes,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      waiterId: waiterId ?? this.waiterId,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  bool get isPending => status == OrderStatus.pending;
  bool get isAccepted => status == OrderStatus.accepted;
  bool get isPreparing => status == OrderStatus.preparing;
  bool get isReady => status == OrderStatus.ready;
  bool get isServed => status == OrderStatus.served;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isActive => !isServed && !isCancelled;
}