// data/datasources/remote/food_remote_source.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/constants/error_constants.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/core/utils/firebase_utils.dart';

class FoodRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = AppConstants.foodItemsCollection;

  // Get all food items
  Stream<List<FoodItem>> getAllFoodItems() {
    return _firestore
        .collection(_collection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FoodItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get all food items (Future)
  Future<List<FoodItem>> getAllFoodItemsFuture() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => FoodItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Get food items by category
  Stream<List<FoodItem>> getFoodItemsByCategory(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('category_id', isEqualTo: categoryId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FoodItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get food items by category (Future)
  Future<List<FoodItem>> getFoodItemsByCategoryFuture(String categoryId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('category_id', isEqualTo: categoryId)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => FoodItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Get available food items
  Stream<List<FoodItem>> getAvailableFoodItems() {
    return _firestore
        .collection(_collection)
        .where('available', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => FoodItem.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get food item by ID
  Future<FoodItem?> getFoodItemById(String foodItemId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(foodItemId).get();

      if (!doc.exists) {
        return null;
      }

      return FoodItem.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Add a new food item
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
      // Check if food item with the same name already exists
      final existingSnapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: name)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        throw Exception(ErrorConstants.foodItemExists);
      }

      // Check if the category exists
      final categoryDoc = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .get();

      if (!categoryDoc.exists) {
        throw Exception(ErrorConstants.categoryNotFound);
      }

      // Upload image to storage if provided
      String imageUrl = '';
      if (imageFile != null) {
        final fileName = path.basename(imageFile.path);
        final destination = '${AppConstants.foodImagesPath}/${const Uuid().v4()}_$fileName';

        final ref = _storage.ref().child(destination);
        final uploadTask = ref.putFile(imageFile);

        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Create the food item
      final foodItemId = FirebaseUtils.generateId();
      final now = DateTime.now();

      final foodItem = FoodItem(
        id: foodItemId,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageUrl: imageUrl,
        available: available,
        preparationTime: preparationTime,
        createdAt: now,
        updatedAt: now,
      );

      // Add to Firestore
      await _firestore
          .collection(_collection)
          .doc(foodItemId)
          .set(foodItem.toJson());

      return foodItem;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToCreate);
    }
  }

  // Update a food item
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
      // Check if the food item exists
      final foodItemDoc = await _firestore.collection(_collection).doc(id).get();

      if (!foodItemDoc.exists) {
        throw Exception(ErrorConstants.foodItemNotFound);
      }

      final existingFoodItem = FoodItem.fromJson(foodItemDoc.data() as Map<String, dynamic>);

      // If name is being updated, check it doesn't conflict
      if (name != null && name != existingFoodItem.name) {
        final existingSnapshot = await _firestore
            .collection(_collection)
            .where('name', isEqualTo: name)
            .get();

        if (existingSnapshot.docs.isNotEmpty) {
          throw Exception(ErrorConstants.foodItemExists);
        }
      }

      // If category is being updated, check it exists
      if (categoryId != null && categoryId != existingFoodItem.categoryId) {
        final categoryDoc = await _firestore
            .collection(AppConstants.categoriesCollection)
            .doc(categoryId)
            .get();

        if (!categoryDoc.exists) {
          throw Exception(ErrorConstants.categoryNotFound);
        }
      }

      // Update image if provided
      String imageUrl = existingFoodItem.imageUrl;
      if (imageFile != null) {
        // Delete existing image if there is one
        if (existingFoodItem.imageUrl.isNotEmpty) {
          try {
            final ref = _storage.refFromURL(existingFoodItem.imageUrl);
            await ref.delete();
          } catch (e) {
            // Ignore if image doesn't exist or can't be deleted
          }
        }

        // Upload new image
        final fileName = path.basename(imageFile.path);
        final destination = '${AppConstants.foodImagesPath}/${const Uuid().v4()}_$fileName';

        final ref = _storage.ref().child(destination);
        final uploadTask = ref.putFile(imageFile);

        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update the food item
      final updatedFoodItem = existingFoodItem.copyWith(
        name: name ?? existingFoodItem.name,
        description: description ?? existingFoodItem.description,
        price: price ?? existingFoodItem.price,
        categoryId: categoryId ?? existingFoodItem.categoryId,
        imageUrl: imageUrl,
        available: available ?? existingFoodItem.available,
        preparationTime: preparationTime ?? existingFoodItem.preparationTime,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedFoodItem.toJson());

      return updatedFoodItem;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Delete a food item
  Future<void> deleteFoodItem(String id) async {
    try {
      // Check if the food item exists
      final foodItemDoc = await _firestore.collection(_collection).doc(id).get();

      if (!foodItemDoc.exists) {
        throw Exception(ErrorConstants.foodItemNotFound);
      }

      final foodItem = FoodItem.fromJson(foodItemDoc.data() as Map<String, dynamic>);

      // Check if there are orders using this food item
      final orderItemsSnapshot = await _firestore
          .collection(AppConstants.orderItemsCollection)
          .where('food_item_id', isEqualTo: id)
          .get();

      if (orderItemsSnapshot.docs.isNotEmpty) {
        throw Exception('Cannot delete food item. It is referenced in ${orderItemsSnapshot.docs.length} order(s).');
      }

      // Delete the image from storage if it exists
      if (foodItem.imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(foodItem.imageUrl);
          await ref.delete();
        } catch (e) {
          // Ignore if image doesn't exist or can't be deleted
        }
      }

      // Delete the food item document
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToDelete);
    }
  }

  // Toggle food item availability
  Future<FoodItem> toggleFoodItemAvailability(String id) async {
    try {
      // Check if the food item exists
      final foodItemDoc = await _firestore.collection(_collection).doc(id).get();

      if (!foodItemDoc.exists) {
        throw Exception(ErrorConstants.foodItemNotFound);
      }

      final existingFoodItem = FoodItem.fromJson(foodItemDoc.data() as Map<String, dynamic>);

      // Toggle availability
      final updatedFoodItem = existingFoodItem.copyWith(
        available: !existingFoodItem.available,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedFoodItem.toJson());

      return updatedFoodItem;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Search food items
  Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      query = query.toLowerCase();

      final nameSnapshot = await _firestore
          .collection(_collection)
          .orderBy('name')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      final descriptionSnapshot = await _firestore
          .collection(_collection)
          .orderBy('description')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get();

      // Combine results and remove duplicates
      final Set<String> ids = {};
      final List<FoodItem> results = [];

      for (var doc in nameSnapshot.docs) {
        final foodItem = FoodItem.fromJson(doc.data() as Map<String, dynamic>);
        if (!ids.contains(foodItem.id)) {
          ids.add(foodItem.id);
          results.add(foodItem);
        }
      }

      for (var doc in descriptionSnapshot.docs) {
        final foodItem = FoodItem.fromJson(doc.data() as Map<String, dynamic>);
        if (!ids.contains(foodItem.id)) {
          ids.add(foodItem.id);
          results.add(foodItem);
        }
      }

      // Sort by name
      results.sort((a, b) => a.name.compareTo(b.name));

      return results;
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }
}