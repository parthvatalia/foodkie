// domain/usecases/table/update_table_status_usecase.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class UpdateTableStatusUseCase {
  final TableRepository _tableRepository;

  UpdateTableStatusUseCase(this._tableRepository);

  Future<TableModel> execute({
    required String id,
    required TableStatus status,
  }) async {
    return await _tableRepository.updateTableStatus(
      id: id,
      status: status,
    );
  }
}