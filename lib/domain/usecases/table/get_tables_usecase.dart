// domain/usecases/table/get_tables_usecase.dart
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class GetTablesUseCase {
  final TableRepository _tableRepository;

  GetTablesUseCase(this._tableRepository);

  Stream<List<TableModel>> execute() {
    return _tableRepository.getAllTables();
  }

  Future<List<TableModel>> executeFuture() async {
    return await _tableRepository.getAllTablesFuture();
  }
}