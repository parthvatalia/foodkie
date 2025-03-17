// data/repositories/table_repository_impl.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/datasources/remote/table_remote_source.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  final TableRemoteSource _remoteSource;

  TableRepositoryImpl(this._remoteSource);

  @override
  Stream<List<TableModel>> getAllTables() {
    return _remoteSource.getAllTables();
  }

  @override
  Future<List<TableModel>> getAllTablesFuture() async {
    try {
      return await _remoteSource.getAllTablesFuture();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Stream<List<TableModel>> getAvailableTables() {
    return _remoteSource.getAvailableTables();
  }

  @override
  Stream<List<TableModel>> getTablesByStatus(TableStatus status) {
    return _remoteSource.getTablesByStatus(status);
  }

  @override
  Future<TableModel?> getTableById(String tableId) async {
    try {
      return await _remoteSource.getTableById(tableId);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TableModel?> getTableByNumber(int number) async {
    try {
      return await _remoteSource.getTableByNumber(number);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TableModel> addTable({
    required int number,
    required int capacity,
    TableStatus status = TableStatus.available,
  }) async {
    try {
      return await _remoteSource.addTable(
        number: number,
        capacity: capacity,
        status: status,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TableModel> updateTable({
    required String id,
    int? number,
    int? capacity,
    TableStatus? status,
  }) async {
    try {
      return await _remoteSource.updateTable(
        id: id,
        number: number,
        capacity: capacity,
        status: status,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> deleteTable(String id) async {
    try {
      await _remoteSource.deleteTable(id);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TableModel> updateTableStatus({
    required String id,
    required TableStatus status,
  }) async {
    try {
      return await _remoteSource.updateTableStatus(
        id: id,
        status: status,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<TableModel>> getTablesWithCapacity(int minCapacity) async {
    try {
      return await _remoteSource.getTablesWithCapacity(minCapacity);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> batchUpdateTables(List<TableModel> tables) async {
    try {
      await _remoteSource.batchUpdateTables(tables);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TableModel> reserveTable(String id) async {
    try {
      return await _remoteSource.reserveTable(id);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<TableModel> cancelReservation(String id) async {
    try {
      return await _remoteSource.cancelReservation(id);
    } catch (e) {
      throw e.toString();
    }
  }
}