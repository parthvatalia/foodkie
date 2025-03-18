// domain/usecases/table/batch_update_tables_usecase.dart
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class BatchUpdateTablesUseCase {
  final TableRepository _tableRepository;

  BatchUpdateTablesUseCase(this._tableRepository);

  Future<void> execute(List<TableModel> tables) async {
    await _tableRepository.batchUpdateTables(tables);
  }
}