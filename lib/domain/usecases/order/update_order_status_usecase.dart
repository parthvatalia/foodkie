// domain/usecases/order/update_order_status_usecase.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/order_model.dart';
import 'package:foodkie/domain/repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _orderRepository;

  UpdateOrderStatusUseCase(this._orderRepository);

  Future<Order> execute({
    required String orderId,
    required OrderStatus status,
  }) async {
    return await _orderRepository.updateOrderStatus(
      orderId: orderId,
      status: status,
    );
  }
}