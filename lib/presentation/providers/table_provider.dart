// presentation/providers/table_provider.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/domain/usecases/table/add_table_usecase.dart';
import 'package:foodkie/domain/usecases/table/batch_update_tables_usecase.dart';
import 'package:foodkie/domain/usecases/table/cancel_reservation_usecase.dart';
import 'package:foodkie/domain/usecases/table/delete_table_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_available_tables_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_table_by_id_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_table_by_number_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_tables_by_status_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_tables_usecase.dart';
import 'package:foodkie/domain/usecases/table/get_tables_with_capacity_usecase.dart';
import 'package:foodkie/domain/usecases/table/reserve_table_usecase.dart';
import 'package:foodkie/domain/usecases/table/update_table_status_usecase.dart';
import 'package:foodkie/domain/usecases/table/update_table_usecase.dart';

enum TableProviderStatus {
  initial,
  loading,
  loaded,
  error,
}

class TableProvider with ChangeNotifier {
  final GetTablesUseCase? getTablesUseCase;
  final GetAvailableTablesUseCase? getAvailableTablesUseCase;
  final GetTablesByStatusUseCase? getTablesByStatusUseCase;
  final GetTableByIdUseCase? getTableByIdUseCase;
  final GetTableByNumberUseCase? getTableByNumberUseCase;
  final GetTablesWithCapacityUseCase? getTablesWithCapacityUseCase;
  final AddTableUseCase? addTableUseCase;
  final UpdateTableUseCase? updateTableUseCase;
  final DeleteTableUseCase? deleteTableUseCase;
  final UpdateTableStatusUseCase? updateTableStatusUseCase;
  final BatchUpdateTablesUseCase? batchUpdateTablesUseCase;
  final ReserveTableUseCase? reserveTableUseCase;
  final CancelReservationUseCase? cancelReservationUseCase;

  TableProvider({
    this.getTablesUseCase,
    this.getAvailableTablesUseCase,
    this.getTablesByStatusUseCase,
    this.getTableByIdUseCase,
    this.getTableByNumberUseCase,
    this.getTablesWithCapacityUseCase,
    this.addTableUseCase,
    this.updateTableUseCase,
    this.deleteTableUseCase,
    this.updateTableStatusUseCase,
    this.batchUpdateTablesUseCase,
    this.reserveTableUseCase,
    this.cancelReservationUseCase,
  });

  List<TableModel> _tables = [];
  TableProviderStatus _status = TableProviderStatus.initial;
  String? _errorMessage;
  TableModel? _selectedTable;
  TableStatus? _filterStatus;

  // Getters
  List<TableModel> get tables => _tables;
  TableProviderStatus get status => _status;
  String? get errorMessage => _errorMessage;
  TableModel? get selectedTable => _selectedTable;
  TableStatus? get filterStatus => _filterStatus;
  bool get isLoading => _status == TableProviderStatus.loading;

  // Get all tables stream
  Stream<List<TableModel>>? getTablesStream() {
    return getTablesUseCase?.execute();
  }

  // Get available tables stream
  Stream<List<TableModel>>? getAvailableTablesStream() {
    return getAvailableTablesUseCase?.execute();
  }

  // Get tables by status stream
  Stream<List<TableModel>>? getTablesByStatusStream(TableStatus status) {
    _filterStatus = status;
    return getTablesByStatusUseCase?.execute(status);
  }

  // Load all tables
  Future<void> loadTables() async {
    try {
      _setStatus(TableProviderStatus.loading);

      // If we have a stream-based implementation
      if (getTablesUseCase != null) {
        getTablesUseCase!.execute().listen(
              (tables) {
            _tables = tables;
            _selectedTable = tables.isNotEmpty ? tables.first : null;
            _setStatus(TableProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(TableProviderStatus.error);
        _setError('Tables use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load available tables
  Future<void> loadAvailableTables() async {
    try {
      _setStatus(TableProviderStatus.loading);
      _filterStatus = TableStatus.available;

      // If we have a stream-based implementation
      if (getAvailableTablesUseCase != null) {
        getAvailableTablesUseCase!.execute().listen(
              (tables) {
            _tables = tables;
            _selectedTable = tables.isNotEmpty ? tables.first : null;
            _setStatus(TableProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(TableProviderStatus.error);
        _setError('Available tables use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load tables by status
  Future<void> loadTablesByStatus(TableStatus status) async {
    try {
      _setStatus(TableProviderStatus.loading);
      _filterStatus = status;

      // If we have a stream-based implementation
      if (getTablesByStatusUseCase != null) {
        getTablesByStatusUseCase!.execute(status).listen(
              (tables) {
            _tables = tables;
            _selectedTable = tables.isNotEmpty ? tables.first : null;
            _setStatus(TableProviderStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(TableProviderStatus.error);
        _setError('Tables by status use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get table by ID
  Future<TableModel?> getTableById(String id) async {
    try {
      _setStatus(TableProviderStatus.loading);
      final table = await getTableByIdUseCase?.execute(id);
      _setStatus(TableProviderStatus.loaded);
      return table;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Get table by number
  Future<TableModel?> getTableByNumber(int number) async {
    try {
      _setStatus(TableProviderStatus.loading);
      final table = await getTableByNumberUseCase?.execute(number);
      _setStatus(TableProviderStatus.loaded);
      return table;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Get tables with minimum capacity
  Future<List<TableModel>> getTablesWithCapacity(int minCapacity) async {
    try {
      _setStatus(TableProviderStatus.loading);
      final tables = await getTablesWithCapacityUseCase?.execute(minCapacity) ?? [];
      _setStatus(TableProviderStatus.loaded);
      return tables;
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Add a new table
  Future<bool> addTable({
    required int number,
    required int capacity,
    TableStatus status = TableStatus.available,
  }) async {
    try {
      _setStatus(TableProviderStatus.loading);

      await addTableUseCase?.execute(
        number: number,
        capacity: capacity,
        status: status,
      );

      _setStatus(TableProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update a table
  Future<bool> updateTable({
    required String id,
    int? number,
    int? capacity,
    TableStatus? status,
  }) async {
    try {
      _setStatus(TableProviderStatus.loading);

      await updateTableUseCase?.execute(
        id: id,
        number: number,
        capacity: capacity,
        status: status,
      );

      _setStatus(TableProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete a table
  Future<bool> deleteTable(String id) async {
    try {
      _setStatus(TableProviderStatus.loading);

      await deleteTableUseCase?.execute(id);

      if (_selectedTable?.id == id) {
        _selectedTable = _tables.isNotEmpty ? _tables.first : null;
      }

      _setStatus(TableProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update table status
  Future<bool> updateTableStatus({
    required String id,
    required TableStatus status,
  }) async {
    try {
      _setStatus(TableProviderStatus.loading);

      await updateTableStatusUseCase?.execute(
        id: id,
        status: status,
      );

      _setStatus(TableProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Batch update tables
  Future<bool> batchUpdateTables(List<TableModel> tables) async {
    try {
      _setStatus(TableProviderStatus.loading);

      await batchUpdateTablesUseCase?.execute(tables);

      _setStatus(TableProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Reserve a table
  Future<bool> reserveTable(String id) async {
    try {
      _setStatus(TableProviderStatus.loading);

      await reserveTableUseCase?.execute(id);

      _setStatus(TableProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Cancel reservation
  Future<bool> cancelReservation(String id) async {
    try {
      _setStatus(TableProviderStatus.loading);

      await cancelReservationUseCase?.execute(id);

      _setStatus(TableProviderStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Set selected table
  void selectTable(TableModel table) {
    _selectedTable = table;
    notifyListeners();
  }

  // Set selected table by ID
  Future<void> selectTableById(String id) async {
    final table = await getTableById(id);
    if (table != null) {
      _selectedTable = table;
      notifyListeners();
    }
  }

  // Helper Methods
  void _setStatus(TableProviderStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = TableProviderStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}