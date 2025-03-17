// domain/usecases/food/add_food_usecase.dart
import 'dart:io';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class AddFoodUseCase {
  final FoodRepository _foodRepository;

  AddFoodUseCase(this._foodRepository);

  Future<FoodItem> execute({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required bool available,
    required int preparationTime,
    File? imageFile,
  }) async {
    return await _foodRepository.addFoodItem(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      available: available,
      preparationTime: preparationTime,
      imageFile: imageFile,
    );
  }
}