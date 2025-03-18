// domain/usecases/order/get_order_history_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class GetOrderHistoryUseCase {
  final OrderRepository _orderRepository;

  GetOrderHistoryUseCase(this._orderRepository);

  Future<List<Order>> execute({int limit = 50}) async {
    return await _orderRepository.getOrderHistory(limit: limit);
  }
}