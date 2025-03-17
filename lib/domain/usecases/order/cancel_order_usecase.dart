// domain/usecases/order/cancel_order_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class CancelOrderUseCase {
  final OrderRepository _orderRepository;

  CancelOrderUseCase(this._orderRepository);

  Future<Order> execute(String orderId) async {
    return await _orderRepository.cancelOrder(orderId);
  }
}