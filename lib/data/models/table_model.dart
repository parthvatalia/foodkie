// data/models/table_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkie/core/enums/app_enums.dart';

class TableModel {
  final String id;
  final int number;
  final int capacity;
  final TableStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TableModel({
    required this.id,
    required this.number,
    required this.capacity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String,
      number: json['number'] as int,
      capacity: json['capacity'] as int,
      status: _tableStatusFromString(json['status'] as String),
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }

  // Helper method to convert string to TableStatus
  static TableStatus _tableStatusFromString(String value) {
    switch (value.toLowerCase()) {
      case 'available':
        return TableStatus.available;
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      default:
        throw ArgumentError('Invalid TableStatus value: $value');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'capacity': capacity,
      'status': _tableStatusToString(status),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to convert TableStatus to string
  static String _tableStatusToString(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'available';
      case TableStatus.occupied:
        return 'occupied';
      case TableStatus.reserved:
        return 'reserved';
    }
  }

  TableModel copyWith({
    String? id,
    int? number,
    int? capacity,
    TableStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TableModel(
      id: id ?? this.id,
      number: number ?? this.number,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}