// domain/usecases/order/accept_order_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class AcceptOrderUseCase {
  final OrderRepository _orderRepository;

  AcceptOrderUseCase(this._orderRepository);

  Future<Order> execute(String orderId) async {
    return await _orderRepository.acceptOrder(orderId);
  }
}