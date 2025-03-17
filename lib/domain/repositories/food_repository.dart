// domain/repositories/food_repository.dart
import 'dart:io';
import 'package:foodkie/data/models/food_item_model.dart';

abstract class FoodRepository {
  Stream<List<FoodItem>> getAllFoodItems();

  Future<List<FoodItem>> getAllFoodItemsFuture();

  Stream<List<FoodItem>> getFoodItemsByCategory(String categoryId);

  Future<List<FoodItem>> getFoodItemsByCategoryFuture(String categoryId);

  Stream<List<FoodItem>> getAvailableFoodItems();

  Future<FoodItem?> getFoodItemById(String foodItemId);

  Future<FoodItem> addFoodItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required bool available,
    required int preparationTime,
    File? imageFile,
  });

  Future<FoodItem> updateFoodItem({
    required String id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    bool? available,
    int? preparationTime,
    File? imageFile,
  });

  Future<void> deleteFoodItem(String id);

  Future<FoodItem> toggleFoodItemAvailability(String id);

  Future<List<FoodItem>> searchFoodItems(String query);
}