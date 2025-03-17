// domain/usecases/order/get_order_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class GetOrderUseCase {
  final OrderRepository _orderRepository;

  GetOrderUseCase(this._orderRepository);

  Future<Order?> execute(String orderId) async {
    return await _orderRepository.getOrderById(orderId);
  }
}