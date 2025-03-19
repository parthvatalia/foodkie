// domain/usecases/order/create_order_usecase.dart
import 'package:foodkie/data/models/order_item_model.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository _orderRepository;

  CreateOrderUseCase(this._orderRepository);

  Future<Order> execute({
    required String tableId,
    required String waiterId,
    required List<OrderItem> items,

    String? notes,
    String? customerName,
  }) async {
    return await _orderRepository.createOrder(
      tableId: tableId,
      waiterId: waiterId,
      items: items,
      notes: notes,
      customerName: customerName,
    );
  }
}