// domain/usecases/table/cancel_reservation_usecase.dart
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class CancelReservationUseCase {
  final TableRepository _tableRepository;

  CancelReservationUseCase(this._tableRepository);

  Future<TableModel> execute(String id) async {
    return await _tableRepository.cancelReservation(id);
  }
}