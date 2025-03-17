// domain/usecases/table/delete_table_usecase.dart
import 'package:foodkie/domain/repositories/table_repository.dart';

class DeleteTableUseCase {
  final TableRepository _tableRepository;

  DeleteTableUseCase(this._tableRepository);

  Future<void> execute(String id) async {
    await _tableRepository.deleteTable(id);
  }
}