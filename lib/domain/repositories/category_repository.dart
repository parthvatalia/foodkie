// domain/repositories/category_repository.dart
import 'dart:io';
import 'package:foodkie/data/models/category_model.dart';

abstract class CategoryRepository {
  Stream<List<Category>> getAllCategories();

  Future<List<Category>> getAllCategoriesFuture();

  Future<Category?> getCategoryById(String categoryId);

  Future<Category> addCategory({
    required String name,
    required String description,
    File? imageFile,
    int? order,
  });

  Future<Category> updateCategory({
    required String id,
    String? name,
    String? description,
    File? imageFile,
    int? order,
  });

  Future<void> deleteCategory(String id);

  Future<void> reorderCategories(List<Category> categories);

  Future<List<Category>> searchCategories(String query);
}