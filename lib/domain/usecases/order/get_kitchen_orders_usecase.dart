// domain/usecases/order/get_kitchen_orders_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class GetKitchenOrdersUseCase {
  final OrderRepository _orderRepository;

  GetKitchenOrdersUseCase(this._orderRepository);

  Stream<List<Order>> execute() {
    return _orderRepository.getOrdersForKitchen();
  }
}