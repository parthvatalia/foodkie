// domain/usecases/table/update_table_usecase.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class UpdateTableUseCase {
  final TableRepository _tableRepository;

  UpdateTableUseCase(this._tableRepository);

  Future<TableModel> execute({
    required String id,
    int? number,
    int? capacity,
    TableStatus? status,
  }) async {
    return await _tableRepository.updateTable(
      id: id,
      number: number,
      capacity: capacity,
      status: status,
    );
  }
}