// domain/usecases/order/remove_item_from_order_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class RemoveItemFromOrderUseCase {
  final OrderRepository _orderRepository;

  RemoveItemFromOrderUseCase(this._orderRepository);

  Future<Order> execute({
    required String orderId,
    required String orderItemId,
  }) async {
    return await _orderRepository.removeItemFromOrder(
      orderId: orderId,
      orderItemId: orderItemId,
    );
  }
}