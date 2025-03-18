// domain/usecases/food/get_food_by_id_usecase.dart
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class GetFoodByIdUseCase {
  final FoodRepository _foodRepository;

  GetFoodByIdUseCase(this._foodRepository);

  Future<FoodItem?> execute(String foodItemId) async {
    return await _foodRepository.getFoodItemById(foodItemId);
  }
}