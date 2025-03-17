// data/datasources/remote/table_remote_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/constants/error_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/table_model.dart';
import 'package:foodkie/core/utils/firebase_utils.dart';

class TableRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = AppConstants.tablesCollection;

  // Get all tables
  Stream<List<TableModel>> getAllTables() {
    return _firestore
        .collection(_collection)
        .orderBy('number')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TableModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get all tables (Future)
  Future<List<TableModel>> getAllTablesFuture() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('number')
          .get();

      return snapshot.docs
          .map((doc) => TableModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Get available tables
  Stream<List<TableModel>> getAvailableTables() {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: TableStatus.available.value)
        .orderBy('number')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TableModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get tables by status
  Stream<List<TableModel>> getTablesByStatus(TableStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.value)
        .orderBy('number')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TableModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get table by ID
  Future<TableModel?> getTableById(String tableId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(tableId).get();

      if (!doc.exists) {
        return null;
      }

      return TableModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Get table by number
  Future<TableModel?> getTableByNumber(int number) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('number', isEqualTo: number)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return TableModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Add a new table
  Future<TableModel> addTable({
    required int number,
    required int capacity,
    TableStatus status = TableStatus.available,
  }) async {
    try {
      // Check if table with the same number already exists
      final existingTable = await getTableByNumber(number);

      if (existingTable != null) {
        throw Exception(ErrorConstants.tableExists);
      }

      // Create the table
      final tableId = FirebaseUtils.generateId();
      final now = DateTime.now();

      final table = TableModel(
        id: tableId,
        number: number,
        capacity: capacity,
        status: status,
        createdAt: now,
        updatedAt: now,
      );

      // Add to Firestore
      await _firestore
          .collection(_collection)
          .doc(tableId)
          .set(table.toJson());

      return table;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToCreate);
    }
  }

  // Update a table
  Future<TableModel> updateTable({
    required String id,
    int? number,
    int? capacity,
    TableStatus? status,
  }) async {
    try {
      // Check if the table exists
      final tableDoc = await _firestore.collection(_collection).doc(id).get();

      if (!tableDoc.exists) {
        throw Exception(ErrorConstants.tableNotFound);
      }

      final existingTable = TableModel.fromJson(tableDoc.data() as Map<String, dynamic>);

      // If number is being updated, check it doesn't conflict
      if (number != null && number != existingTable.number) {
        final existingByNumber = await getTableByNumber(number);

        if (existingByNumber != null) {
          throw Exception(ErrorConstants.tableExists);
        }
      }

      // Update the table
      final updatedTable = existingTable.copyWith(
        number: number ?? existingTable.number,
        capacity: capacity ?? existingTable.capacity,
        status: status ?? existingTable.status,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedTable.toJson());

      return updatedTable;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Delete a table
  Future<void> deleteTable(String id) async {
    try {
      // Check if the table exists
      final tableDoc = await _firestore.collection(_collection).doc(id).get();

      if (!tableDoc.exists) {
        throw Exception(ErrorConstants.tableNotFound);
      }

      final table = TableModel.fromJson(tableDoc.data() as Map<String, dynamic>);

      // Check if there are active orders for this table
      if (table.status == TableStatus.occupied) {
        final ordersSnapshot = await _firestore
            .collection(AppConstants.ordersCollection)
            .where('table_id', isEqualTo: id)
            .where('status', whereIn: [
          OrderStatus.pending.value,
          OrderStatus.accepted.value,
          OrderStatus.preparing.value,
          OrderStatus.ready.value,
        ])
            .get();

        if (ordersSnapshot.docs.isNotEmpty) {
          throw Exception('Cannot delete table. It has active orders.');
        }
      }

      // Delete the table document
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToDelete);
    }
  }

  // Update table status
  Future<TableModel> updateTableStatus({
    required String id,
    required TableStatus status,
  }) async {
    try {
      // Check if the table exists
      final tableDoc = await _firestore.collection(_collection).doc(id).get();

      if (!tableDoc.exists) {
        throw Exception(ErrorConstants.tableNotFound);
      }

      final existingTable = TableModel.fromJson(tableDoc.data() as Map<String, dynamic>);

      // Check existing status and new status
      if (existingTable.status == TableStatus.occupied && status == TableStatus.available) {
        // Check if there are active orders for this table
        final ordersSnapshot = await _firestore
            .collection(AppConstants.ordersCollection)
            .where('table_id', isEqualTo: id)
            .where('status', whereIn: [
          OrderStatus.pending.value,
          OrderStatus.accepted.value,
          OrderStatus.preparing.value,
          OrderStatus.ready.value,
        ])
            .get();

        if (ordersSnapshot.docs.isNotEmpty) {
          throw Exception('Cannot change table status. It has active orders.');
        }
      }

      // Update the table status
      final updatedTable = existingTable.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedTable.toJson());

      return updatedTable;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Get tables with capacity
  Future<List<TableModel>> getTablesWithCapacity(int minCapacity) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('capacity', isGreaterThanOrEqualTo: minCapacity)
          .orderBy('capacity')
          .orderBy('number')
          .get();

      return snapshot.docs
          .map((doc) => TableModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Batch update multiple tables
  Future<void> batchUpdateTables(List<TableModel> tables) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();

      for (var table in tables) {
        final tableRef = _firestore.collection(_collection).doc(table.id);
        final updatedTable = table.copyWith(updatedAt: now);

        batch.update(tableRef, updatedTable.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Reserve a table
  Future<TableModel> reserveTable(String id) async {
    try {
      // Check if the table exists and is available
      final tableDoc = await _firestore.collection(_collection).doc(id).get();

      if (!tableDoc.exists) {
        throw Exception(ErrorConstants.tableNotFound);
      }

      final existingTable = TableModel.fromJson(tableDoc.data() as Map<String, dynamic>);

      if (existingTable.status != TableStatus.available) {
        throw Exception(ErrorConstants.tableNotAvailable);
      }

      // Update the table status to reserved
      final updatedTable = existingTable.copyWith(
        status: TableStatus.reserved,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedTable.toJson());

      return updatedTable;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Cancel reservation
  Future<TableModel> cancelReservation(String id) async {
    try {
      // Check if the table exists and is reserved
      final tableDoc = await _firestore.collection(_collection).doc(id).get();

      if (!tableDoc.exists) {
        throw Exception(ErrorConstants.tableNotFound);
      }

      final existingTable = TableModel.fromJson(tableDoc.data() as Map<String, dynamic>);

      if (existingTable.status != TableStatus.reserved) {
        throw Exception('Table is not reserved');
      }

      // Update the table status to available
      final updatedTable = existingTable.copyWith(
        status: TableStatus.available,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedTable.toJson());

      return updatedTable;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }
}