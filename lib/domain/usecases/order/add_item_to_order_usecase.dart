// domain/usecases/order/add_item_to_order_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class AddItemToOrderUseCase {
  final OrderRepository _orderRepository;

  AddItemToOrderUseCase(this._orderRepository);

  Future<Order> execute({
    required String orderId,
    required String foodItemId,
    required int quantity,
    String? notes,
  }) async {
    return await _orderRepository.addItemToOrder(
      orderId: orderId,
      foodItemId: foodItemId,
      quantity: quantity,
      notes: notes,
    );
  }
}



