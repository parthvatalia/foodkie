// domain/usecases/food/toggle_food_availability_usecase.dart
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class ToggleFoodAvailabilityUseCase {
  final FoodRepository _foodRepository;

  ToggleFoodAvailabilityUseCase(this._foodRepository);

  Future<FoodItem> execute(String id) async {
    return await _foodRepository.toggleFoodItemAvailability(id);
  }
}