// data/repositories/category_repository_impl.dart
import 'dart:io';
import 'package:foodkie/data/datasources/remote/category_remote_source.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteSource _remoteSource;

  CategoryRepositoryImpl(this._remoteSource);

  @override
  Stream<List<Category>> getAllCategories() {
    return _remoteSource.getAllCategories();
  }

  @override
  Future<List<Category>> getAllCategoriesFuture() async {
    try {
      return await _remoteSource.getAllCategoriesFuture();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      return await _remoteSource.getCategoryById(categoryId);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Category> addCategory({
    required String name,
    required String description,
    File? imageFile,
    int? order,
  }) async {
    try {
      return await _remoteSource.addCategory(
        name: name,
        description: description,
        imageFile: imageFile,
        order: order,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<Category> updateCategory({
    required String id,
    String? name,
    String? description,
    File? imageFile,
    int? order,
  }) async {
    try {
      return await _remoteSource.updateCategory(
        id: id,
        name: name,
        description: description,
        imageFile: imageFile,
        order: order,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await _remoteSource.deleteCategory(id);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> reorderCategories(List<Category> categories) async {
    try {
      await _remoteSource.reorderCategories(categories);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    try {
      return await _remoteSource.searchCategories(query);
    } catch (e) {
      throw e.toString();
    }
  }
}