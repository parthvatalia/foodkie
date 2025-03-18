// domain/usecases/order/get_table_orders_usecase.dart
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class GetTableOrdersUseCase {
  final OrderRepository _orderRepository;

  GetTableOrdersUseCase(this._orderRepository);

  Stream<List<Order>> execute(String tableId) {
    return _orderRepository.getOrdersByTable(tableId);
  }

  Future<Order?> getActiveOrder(String tableId) async {
    return await _orderRepository.getActiveOrderByTable(tableId);
  }
}