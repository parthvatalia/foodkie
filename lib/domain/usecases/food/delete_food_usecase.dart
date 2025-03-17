
// domain/usecases/food/delete_food_usecase.dart
import 'package:foodkie/domain/repositories/food_repository.dart';

class DeleteFoodUseCase {
  final FoodRepository _foodRepository;

  DeleteFoodUseCase(this._foodRepository);

  Future<void> execute(String id) async {
    await _foodRepository.deleteFoodItem(id);
  }
}