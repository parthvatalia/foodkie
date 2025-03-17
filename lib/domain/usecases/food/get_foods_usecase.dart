
// domain/usecases/food/get_foods_usecase.dart
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class GetFoodsUseCase {
  final FoodRepository _foodRepository;

  GetFoodsUseCase(this._foodRepository);

  Stream<List<FoodItem>> execute() {
    return _foodRepository.getAllFoodItems();
  }

  Future<List<FoodItem>> executeFuture() async {
    return await _foodRepository.getAllFoodItemsFuture();
  }
}