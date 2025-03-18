// domain/usecases/table/get_available_tables_usecase.dart
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class GetAvailableTablesUseCase {
  final TableRepository _tableRepository;

  GetAvailableTablesUseCase(this._tableRepository);

  Stream<List<TableModel>> execute() {
    return _tableRepository.getAvailableTables();
  }
}