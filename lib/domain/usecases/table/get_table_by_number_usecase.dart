// domain/usecases/table/get_table_by_number_usecase.dart
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class GetTableByNumberUseCase {
  final TableRepository _tableRepository;

  GetTableByNumberUseCase(this._tableRepository);

  Future<TableModel?> execute(int number) async {
    return await _tableRepository.getTableByNumber(number);
  }
}