// domain/usecases/table/get_table_by_id_usecase.dart
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class GetTableByIdUseCase {
  final TableRepository _tableRepository;

  GetTableByIdUseCase(this._tableRepository);

  Future<TableModel?> execute(String tableId) async {
    return await _tableRepository.getTableById(tableId);
  }
}