// domain/usecases/table/get_tables_by_status_usecase.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class GetTablesByStatusUseCase {
  final TableRepository _tableRepository;

  GetTablesByStatusUseCase(this._tableRepository);

  Stream<List<TableModel>> execute(TableStatus status) {
    return _tableRepository.getTablesByStatus(status);
  }
}