// domain/usecases/order/serve_order_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class ServeOrderUseCase {
  final OrderRepository _orderRepository;

  ServeOrderUseCase(this._orderRepository);

  Future<Order> execute(String orderId) async {
    return await _orderRepository.markOrderAsServed(orderId);
  }
}