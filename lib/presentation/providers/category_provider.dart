// presentation/providers/category_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/usecases/category/add_category_usecase.dart';
import 'package:foodkie/domain/usecases/category/delete_category_usecase.dart';
import 'package:foodkie/domain/usecases/category/get_categories_usecase.dart';
import 'package:foodkie/domain/usecases/category/get_category_by_id_usecase.dart';
import 'package:foodkie/domain/usecases/category/reorder_categories_usecase.dart';
import 'package:foodkie/domain/usecases/category/search_categories_usecase.dart';
import 'package:foodkie/domain/usecases/category/update_category_usecase.dart';

enum CategoryStatus {
  initial,
  loading,
  loaded,
  error,
}

class CategoryProvider with ChangeNotifier {
  final GetCategoriesUseCase? getCategoriesUseCase;
  final GetCategoryByIdUseCase? getCategoryByIdUseCase;
  final AddCategoryUseCase? addCategoryUseCase;
  final UpdateCategoryUseCase? updateCategoryUseCase;
  final DeleteCategoryUseCase? deleteCategoryUseCase;
  final ReorderCategoriesUseCase? reorderCategoriesUseCase;
  final SearchCategoriesUseCase? searchCategoriesUseCase;

  CategoryProvider({
    this.getCategoriesUseCase,
    this.getCategoryByIdUseCase,
    this.addCategoryUseCase,
    this.updateCategoryUseCase,
    this.deleteCategoryUseCase,
    this.reorderCategoriesUseCase,
    this.searchCategoriesUseCase,
  });

  List<Category> _categories = [];
  CategoryStatus _status = CategoryStatus.initial;
  String? _errorMessage;
  Category? _selectedCategory;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Category> _searchResults = [];

  // Getters
  List<Category> get categories => _categories;
  CategoryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Category? get selectedCategory => _selectedCategory;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  List<Category> get searchResults => _searchResults;
  bool get isLoading => _status == CategoryStatus.loading;

  // Fetch all categories
  Stream<List<Category>>? getCategoriesStream() {
    return getCategoriesUseCase?.execute();
  }

  // Load categories initially or refresh
  Future<void> loadCategories() async {
    try {
      _setStatus(CategoryStatus.loading);

      // If we have a stream-based implementation
      if (getCategoriesUseCase != null) {
        getCategoriesUseCase!.execute().listen(
              (categories) {
            _categories = categories;
            _selectedCategory = categories.isNotEmpty ? categories.first : null;
            _setStatus(CategoryStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(CategoryStatus.error);
        _setError('Categories use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get category by ID
  Future<Category?> getCategoryById(String id) async {
    try {
      _setStatus(CategoryStatus.loading);
      final category = await getCategoryByIdUseCase?.execute(id);
      _setStatus(CategoryStatus.loaded);
      return category;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Add a new category
  Future<bool> addCategory({
    required String name,
    required String description,
    File? imageFile,
    int? order,
  }) async {
    try {
      _setStatus(CategoryStatus.loading);

      await addCategoryUseCase?.execute(
        name: name,
        description: description,
        imageFile: imageFile,
        order: order,
      );

      _setStatus(CategoryStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update a category
  Future<bool> updateCategory({
    required String id,
    String? name,
    String? description,
    File? imageFile,
    int? order,
  }) async {
    try {
      _setStatus(CategoryStatus.loading);

      await updateCategoryUseCase?.execute(
        id: id,
        name: name,
        description: description,
        imageFile: imageFile,
        order: order,
      );

      _setStatus(CategoryStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(String id) async {
    try {
      _setStatus(CategoryStatus.loading);

      await deleteCategoryUseCase?.execute(id);

      if (_selectedCategory?.id == id) {
        _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
      }

      _setStatus(CategoryStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Reorder categories
  Future<bool> reorderCategories(List<Category> reorderedCategories) async {
    try {
      _setStatus(CategoryStatus.loading);

      await reorderCategoriesUseCase?.execute(reorderedCategories);

      _setStatus(CategoryStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Search categories
  Future<void> searchCategories(String query) async {
    try {
      if (query.isEmpty) {
        _isSearching = false;
        _searchQuery = '';
        _searchResults = [];
        notifyListeners();
        return;
      }

      _isSearching = true;
      _searchQuery = query;
      notifyListeners();

      final results = await searchCategoriesUseCase?.execute(query);

      _searchResults = results ?? [];
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Clear search
  void clearSearch() {
    _isSearching = false;
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  // Set selected category
  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // Set selected category by ID
  Future<void> selectCategoryById(String id) async {
    final category = await getCategoryById(id);
    if (category != null) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // Helper Methods
  void _setStatus(CategoryStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = CategoryStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}