// domain/usecases/order/update_item_quantity_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class UpdateItemQuantityUseCase {
  final OrderRepository _orderRepository;

  UpdateItemQuantityUseCase(this._orderRepository);

  Future<Order> execute({
    required String orderId,
    required String orderItemId,
    required int quantity,
  }) async {
    return await _orderRepository.updateItemQuantity(
      orderId: orderId,
      orderItemId: orderItemId,
      quantity: quantity,
    );
  }
}