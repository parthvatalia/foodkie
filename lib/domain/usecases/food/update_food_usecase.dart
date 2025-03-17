// domain/usecases/food/update_food_usecase.dart
import 'dart:io';
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class UpdateFoodUseCase {
  final FoodRepository _foodRepository;

  UpdateFoodUseCase(this._foodRepository);

  Future<FoodItem> execute({
    required String id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    bool? available,
    int? preparationTime,
    File? imageFile,
  }) async {
    return await _foodRepository.updateFoodItem(
      id: id,
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