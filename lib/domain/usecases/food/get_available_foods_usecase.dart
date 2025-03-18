// domain/usecases/food/get_available_foods_usecase.dart
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class GetAvailableFoodsUseCase {
  final FoodRepository _foodRepository;

  GetAvailableFoodsUseCase(this._foodRepository);

  Stream<List<FoodItem>> execute() {
    return _foodRepository.getAvailableFoodItems();
  }
}