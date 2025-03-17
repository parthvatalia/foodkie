// domain/usecases/table/add_table_usecase.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class AddTableUseCase {
  final TableRepository _tableRepository;

  AddTableUseCase(this._tableRepository);

  Future<TableModel> execute({
    required int number,
    required int capacity,
    TableStatus status = TableStatus.available,
  }) async {
    return await _tableRepository.addTable(
      number: number,
      capacity: capacity,
      status: status,
    );
  }
}