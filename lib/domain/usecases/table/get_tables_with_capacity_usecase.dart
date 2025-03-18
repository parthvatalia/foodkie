// domain/usecases/table/get_tables_with_capacity_usecase.dart
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class GetTablesWithCapacityUseCase {
  final TableRepository _tableRepository;

  GetTablesWithCapacityUseCase(this._tableRepository);

  Future<List<TableModel>> execute(int minCapacity) async {
    return await _tableRepository.getTablesWithCapacity(minCapacity);
  }
}