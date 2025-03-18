import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class ReserveTableUseCase {
  final TableRepository _tableRepository;

  ReserveTableUseCase(this._tableRepository);

  Future<TableModel> execute(String id) async {
    return await _tableRepository.reserveTable(id);
  }
}