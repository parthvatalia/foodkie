// domain/usecases/order/mark_order_ready_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class MarkOrderReadyUseCase {
  final OrderRepository _orderRepository;

  MarkOrderReadyUseCase(this._orderRepository);

  Future<Order> execute(String orderId) async {
    return await _orderRepository.markOrderAsReady(orderId);
  }
}