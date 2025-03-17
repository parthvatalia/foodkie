// domain/usecases/order/get_waiter_orders_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class GetWaiterOrdersUseCase {
  final OrderRepository _orderRepository;

  GetWaiterOrdersUseCase(this._orderRepository);

  Stream<List<Order>> execute(String waiterId) {
    return _orderRepository.getOrdersByWaiter(waiterId);
  }

  Stream<List<Order>> executeActiveOnly(String waiterId) {
    return _orderRepository.getActiveOrdersByWaiter(waiterId);
  }
}