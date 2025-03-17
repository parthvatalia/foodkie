// core/enums/app_enums.dart

// User roles
enum UserRole {
  manager,
  waiter,
  kitchen
}

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.manager:
        return 'Manager';
      case UserRole.waiter:
        return 'Waiter';
      case UserRole.kitchen:
        return 'Kitchen';
    }
  }

  String get value {
    switch (this) {
      case UserRole.manager:
        return 'manager';
      case UserRole.waiter:
        return 'waiter';
      case UserRole.kitchen:
        return 'kitchen';
    }
  }

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'manager':
        return UserRole.manager;
      case 'waiter':
        return UserRole.waiter;
      case 'kitchen':
        return UserRole.kitchen;
      default:
        throw ArgumentError('Invalid UserRole value: $value');
    }
  }
}

// Order status
enum OrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  served,
  cancelled
}

extension OrderStatusExtension on OrderStatus {
  String get name {
    switch (this) {
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

  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.served:
        return 'served';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'served':
        return OrderStatus.served;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        throw ArgumentError('Invalid OrderStatus value: $value');
    }
  }
}

// Table status
enum TableStatus {
  available,
  occupied,
  reserved
}

extension TableStatusExtension on TableStatus {
  String get name {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
    }
  }

  String get value {
    switch (this) {
      case TableStatus.available:
        return 'available';
      case TableStatus.occupied:
        return 'occupied';
      case TableStatus.reserved:
        return 'reserved';
    }
  }

  static TableStatus fromString(String value) {
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
}