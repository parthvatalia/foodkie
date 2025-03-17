// presentation/providers/food_item_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/usecases/food/add_food_usecase.dart';
import 'package:foodkie/domain/usecases/food/delete_food_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_available_foods_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_food_by_id_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_foods_by_category_usecase.dart';
import 'package:foodkie/domain/usecases/food/get_foods_usecase.dart';
import 'package:foodkie/domain/usecases/food/search_foods_usecase.dart';
import 'package:foodkie/domain/usecases/food/toggle_food_availability_usecase.dart';
import 'package:foodkie/domain/usecases/food/update_food_usecase.dart';

enum FoodItemStatus {
  initial,
  loading,
  loaded,
  error,
}

class FoodItemProvider with ChangeNotifier {
  final GetFoodsUseCase? getFoodsUseCase;
  final GetFoodsByCategoryUseCase? getFoodsByCategoryUseCase;
  final GetFoodByIdUseCase? getFoodByIdUseCase;
  final GetAvailableFoodsUseCase? getAvailableFoodsUseCase;
  final AddFoodUseCase? addFoodUseCase;
  final UpdateFoodUseCase? updateFoodUseCase;
  final DeleteFoodUseCase? deleteFoodUseCase;
  final ToggleFoodAvailabilityUseCase? toggleFoodAvailabilityUseCase;
  final SearchFoodsUseCase? searchFoodsUseCase;

  FoodItemProvider({
    this.getFoodsUseCase,
    this.getFoodsByCategoryUseCase,
    this.getFoodByIdUseCase,
    this.getAvailableFoodsUseCase,
    this.addFoodUseCase,
    this.updateFoodUseCase,
    this.deleteFoodUseCase,
    this.toggleFoodAvailabilityUseCase,
    this.searchFoodsUseCase,
  });

  List<FoodItem> _foodItems = [];
  FoodItemStatus _status = FoodItemStatus.initial;
  String? _errorMessage;
  FoodItem? _selectedFoodItem;
  bool _isSearching = false;
  String _searchQuery = '';
  List<FoodItem> _searchResults = [];
  String? _selectedCategoryId;

  // Getters
  List<FoodItem> get foodItems => _foodItems;
  FoodItemStatus get status => _status;
  String? get errorMessage => _errorMessage;
  FoodItem? get selectedFoodItem => _selectedFoodItem;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  List<FoodItem> get searchResults => _searchResults;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _status == FoodItemStatus.loading;

  // Get all food items stream
  Stream<List<FoodItem>>? getFoodItemsStream() {
    return getFoodsUseCase?.execute();
  }

  // Get food items by category stream
  Stream<List<FoodItem>>? getFoodItemsByCategoryStream(String categoryId) {
    _selectedCategoryId = categoryId;
    return getFoodsByCategoryUseCase?.execute(categoryId);
  }

  // Get available food items stream
  Stream<List<FoodItem>>? getAvailableFoodItemsStream() {
    return getAvailableFoodsUseCase?.execute();
  }

  // Load all food items
  Future<void> loadFoodItems() async {
    try {
      _setStatus(FoodItemStatus.loading);

      // If we have a stream-based implementation
      if (getFoodsUseCase != null) {
        getFoodsUseCase!.execute().listen(
              (foodItems) {
            _foodItems = foodItems;
            _selectedFoodItem = foodItems.isNotEmpty ? foodItems.first : null;
            _setStatus(FoodItemStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(FoodItemStatus.error);
        _setError('Food items use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load food items by category
  Future<void> loadFoodItemsByCategory(String categoryId) async {
    try {
      _setStatus(FoodItemStatus.loading);
      _selectedCategoryId = categoryId;

      // If we have a stream-based implementation
      if (getFoodsByCategoryUseCase != null) {
        getFoodsByCategoryUseCase!.execute(categoryId).listen(
              (foodItems) {
            _foodItems = foodItems;
            _selectedFoodItem = foodItems.isNotEmpty ? foodItems.first : null;
            _setStatus(FoodItemStatus.loaded);
          },
          onError: (error) {
            _setError(error.toString());
          },
        );
      } else {
        _setStatus(FoodItemStatus.error);
        _setError('Food items by category use case not implemented');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Get food item by ID
  Future<FoodItem?> getFoodItemById(String id) async {
    try {
      _setStatus(FoodItemStatus.loading);
      final foodItem = await getFoodByIdUseCase?.execute(id);
      _setStatus(FoodItemStatus.loaded);
      return foodItem;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  // Add a new food item
  Future<bool> addFoodItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required bool available,
    required int preparationTime,
    File? imageFile,
  }) async {
    try {
      _setStatus(FoodItemStatus.loading);

      await addFoodUseCase?.execute(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        available: available,
        preparationTime: preparationTime,
        imageFile: imageFile,
      );

      _setStatus(FoodItemStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update a food item
  Future<bool> updateFoodItem({
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
      _setStatus(FoodItemStatus.loading);

      await updateFoodUseCase?.execute(
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        available: available,
        preparationTime: preparationTime,
        imageFile: imageFile,
      );

      _setStatus(FoodItemStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete a food item
  Future<bool> deleteFoodItem(String id) async {
    try {
      _setStatus(FoodItemStatus.loading);

      await deleteFoodUseCase?.execute(id);

      if (_selectedFoodItem?.id == id) {
        _selectedFoodItem = _foodItems.isNotEmpty ? _foodItems.first : null;
      }

      _setStatus(FoodItemStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Toggle food item availability
  Future<bool> toggleFoodItemAvailability(String id) async {
    try {
      _setStatus(FoodItemStatus.loading);

      await toggleFoodAvailabilityUseCase?.execute(id);

      _setStatus(FoodItemStatus.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Search food items
  Future<void> searchFoodItems(String query) async {
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

      final results = await searchFoodsUseCase?.execute(query);

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

  // Set selected food item
  void selectFoodItem(FoodItem foodItem) {
    _selectedFoodItem = foodItem;
    notifyListeners();
  }

  // Set selected food item by ID
  Future<void> selectFoodItemById(String id) async {
    final foodItem = await getFoodItemById(id);
    if (foodItem != null) {
      _selectedFoodItem = foodItem;
      notifyListeners();
    }
  }

  // Helper Methods
  void _setStatus(FoodItemStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _status = FoodItemStatus.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}