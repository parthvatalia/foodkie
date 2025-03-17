// domain/repositories/table_repository.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';

abstract class TableRepository {
  Stream<List<TableModel>> getAllTables();

  Future<List<TableModel>> getAllTablesFuture();

  Stream<List<TableModel>> getAvailableTables();

  Stream<List<TableModel>> getTablesByStatus(TableStatus status);

  Future<TableModel?> getTableById(String tableId);

  Future<TableModel?> getTableByNumber(int number);

  Future<TableModel> addTable({
    required int number,
    required int capacity,
    TableStatus status = TableStatus.available,
  });

  Future<TableModel> updateTable({
    required String id,
    int? number,
    int? capacity,
    TableStatus? status,
  });

  Future<void> deleteTable(String id);

  Future<TableModel> updateTableStatus({
    required String id,
    required TableStatus status,
  });

  Future<List<TableModel>> getTablesWithCapacity(int minCapacity);

  Future<void> batchUpdateTables(List<TableModel> tables);

  Future<TableModel> reserveTable(String id);

  Future<TableModel> cancelReservation(String id);
}