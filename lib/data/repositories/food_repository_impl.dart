// data/repositories/food_repository_impl.dart
import 'dart:io';
import 'package:foodkie/data/datasources/remote/food_remote_source.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteSource _remoteSource;

  FoodRepositoryImpl(this._remoteSource);

  @override
  Stream<List<FoodItem>> getAllFoodItems() {
    return _remoteSource.getAllFoodItems();
  }

  @override
  Future<List<FoodItem>> getAllFoodItemsFuture() async {
    try {
      return await _remoteSource.getAllFoodItemsFuture();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Stream<List<FoodItem>> getFoodItemsByCategory(String categoryId) {
    return _remoteSource.getFoodItemsByCategory(categoryId);
  }

  @override
  Future<List<FoodItem>> getFoodItemsByCategoryFuture(String categoryId) async {
    try {
      return await _remoteSource.getFoodItemsByCategoryFuture(categoryId);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Stream<List<FoodItem>> getAvailableFoodItems() {
    return _remoteSource.getAvailableFoodItems();
  }

  @override
  Future<FoodItem?> getFoodItemById(String foodItemId) async {
    try {
      return await _remoteSource.getFoodItemById(foodItemId);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<FoodItem> addFoodItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required bool available,
    required int preparationTime,
    File? imageFile,
  }) async {
    try {
      return await _remoteSource.addFoodItem(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        available: available,
        preparationTime: preparationTime,
        imageFile: imageFile,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<FoodItem> updateFoodItem({
    required String id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    bool? available,
    int? preparationTime,
    File? imageFile,
  }) async {
    try {
      return await _remoteSource.updateFoodItem(
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        available: available,
        preparationTime: preparationTime,
        imageFile: imageFile,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> deleteFoodItem(String id) async {
    try {
      await _remoteSource.deleteFoodItem(id);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<FoodItem> toggleFoodItemAvailability(String id) async {
    try {
      return await _remoteSource.toggleFoodItemAvailability(id);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      return await _remoteSource.searchFoodItems(query);
    } catch (e) {
      throw e.toString();
    }
  }
}