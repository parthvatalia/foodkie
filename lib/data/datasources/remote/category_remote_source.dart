// data/datasources/remote/category_remote_source.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/constants/error_constants.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/core/utils/firebase_utils.dart';

class CategoryRemoteSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = AppConstants.categoriesCollection;

  // Get all categories
  Stream<List<Category>> getAllCategories() {
    return _firestore
        .collection(_collection)
        .orderBy('order', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
        .toList());
  }

  // Get all categories (Future)
  Future<List<Category>> getAllCategoriesFuture() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => Category.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(categoryId).get();

      if (!doc.exists) {
        return null;
      }

      return Category.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }

  // Add a new category
  Future<Category> addCategory({
    required String name,
    required String description,
    File? imageFile,
    int? order,
  }) async {
    try {
      // Check if category with the same name already exists
      final existingSnapshot = await _firestore
          .collection(_collection)
          .where('name', isEqualTo: name)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        throw Exception(ErrorConstants.categoryExists);
      }

      // Upload image to storage if provided
      String imageUrl = '';
      if (imageFile != null) {
        final fileName = path.basename(imageFile.path);
        final destination = '${AppConstants.categoryImagesPath}/${const Uuid().v4()}_$fileName';

        final ref = _storage.ref().child(destination);
        final uploadTask = ref.putFile(imageFile);

        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Get the highest order value to place new category at the end
      int newOrder = order ?? AppConstants.defaultCategoryOrder;
      if (order == null) {
        final lastCategory = await _firestore
            .collection(_collection)
            .orderBy('order', descending: true)
            .limit(1)
            .get();

        if (lastCategory.docs.isNotEmpty) {
          final lastOrder = lastCategory.docs.first.data()['order'] as int;
          newOrder = lastOrder + 1;
        } else {
          // First category, start with order 1
          newOrder = 1;
        }
      }

      // Create the category
      final categoryId = FirebaseUtils.generateId();
      final now = DateTime.now();

      final category = Category(
        id: categoryId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        order: newOrder,
        createdAt: now,
        updatedAt: now,
      );

      // Add to Firestore
      await _firestore
          .collection(_collection)
          .doc(categoryId)
          .set(category.toJson());

      return category;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToCreate);
    }
  }

  // Update a category
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? description,
    File? imageFile,
    int? order,
  }) async {
    try {
      // Check if the category exists
      final categoryDoc = await _firestore.collection(_collection).doc(id).get();

      if (!categoryDoc.exists) {
        throw Exception(ErrorConstants.categoryNotFound);
      }

      final existingCategory = Category.fromJson(categoryDoc.data() as Map<String, dynamic>);

      // If name is being updated, check it doesn't conflict
      if (name != null && name != existingCategory.name) {
        final existingSnapshot = await _firestore
            .collection(_collection)
            .where('name', isEqualTo: name)
            .get();

        if (existingSnapshot.docs.isNotEmpty) {
          throw Exception(ErrorConstants.categoryExists);
        }
      }

      // Update image if provided
      String imageUrl = existingCategory.imageUrl;
      if (imageFile != null) {
        // Delete existing image if there is one
        if (existingCategory.imageUrl.isNotEmpty) {
          try {
            final ref = _storage.refFromURL(existingCategory.imageUrl);
            await ref.delete();
          } catch (e) {
            // Ignore if image doesn't exist or can't be deleted
          }
        }

        // Upload new image
        final fileName = path.basename(imageFile.path);
        final destination = '${AppConstants.categoryImagesPath}/${const Uuid().v4()}_$fileName';

        final ref = _storage.ref().child(destination);
        final uploadTask = ref.putFile(imageFile);

        final snapshot = await uploadTask.whenComplete(() => null);
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // Update the category
      final updatedCategory = existingCategory.copyWith(
        name: name ?? existingCategory.name,
        description: description ?? existingCategory.description,
        imageUrl: imageUrl,
        order: order ?? existingCategory.order,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedCategory.toJson());

      return updatedCategory;
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      // Check if the category exists
      final categoryDoc = await _firestore.collection(_collection).doc(id).get();

      if (!categoryDoc.exists) {
        throw Exception(ErrorConstants.categoryNotFound);
      }

      final category = Category.fromJson(categoryDoc.data() as Map<String, dynamic>);

      // Check if there are food items using this category
      final foodItemsSnapshot = await _firestore
          .collection(AppConstants.foodItemsCollection)
          .where('category_id', isEqualTo: id)
          .get();

      if (foodItemsSnapshot.docs.isNotEmpty) {
        throw Exception('Cannot delete category. It is used by ${foodItemsSnapshot.docs.length} food items.');
      }

      // Delete the image from storage if it exists
      if (category.imageUrl.isNotEmpty) {
        try {
          final ref = _storage.refFromURL(category.imageUrl);
          await ref.delete();
        } catch (e) {
          // Ignore if image doesn't exist or can't be deleted
        }
      }

      // Delete the category document
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception(ErrorConstants.failedToDelete);
    }
  }

  // Reorder categories
  Future<void> reorderCategories(List<Category> categories) async {
    try {
      // Create a batch to update all categories at once
      final batch = _firestore.batch();

      for (int i = 0; i < categories.length; i++) {
        final category = categories[i];
        final updatedCategory = category.copyWith(
          order: i + 1,
          updatedAt: DateTime.now(),
        );

        final docRef = _firestore.collection(_collection).doc(category.id);
        batch.update(docRef, updatedCategory.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception(ErrorConstants.failedToUpdate);
    }
  }

  // Search categories
  Future<List<Category>> searchCategories(String query) async {
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
      final List<Category> results = [];

      for (var doc in nameSnapshot.docs) {
        final category = Category.fromJson(doc.data() as Map<String, dynamic>);
        if (!ids.contains(category.id)) {
          ids.add(category.id);
          results.add(category);
        }
      }

      for (var doc in descriptionSnapshot.docs) {
        final category = Category.fromJson(doc.data() as Map<String, dynamic>);
        if (!ids.contains(category.id)) {
          ids.add(category.id);
          results.add(category);
        }
      }

      // Sort by order
      results.sort((a, b) => a.order.compareTo(b.order));

      return results;
    } catch (e) {
      throw Exception(ErrorConstants.failedToFetch);
    }
  }
}