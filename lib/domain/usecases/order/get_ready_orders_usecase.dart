// domain/usecases/order/get_ready_orders_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class GetReadyOrdersUseCase {
  final OrderRepository _orderRepository;

  GetReadyOrdersUseCase(this._orderRepository);

  Stream<List<Order>> execute() {
    return _orderRepository.getReadyOrdersForKitchen();
  }
}