
// domain/usecases/food/get_foods_by_category_usecase.dart
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class GetFoodsByCategoryUseCase {
  final FoodRepository _foodRepository;

  GetFoodsByCategoryUseCase(this._foodRepository);

  Stream<List<FoodItem>> execute(String categoryId) {
    return _foodRepository.getFoodItemsByCategory(categoryId);
  }

  Future<List<FoodItem>> executeFuture(String categoryId) async {
    return await _foodRepository.getFoodItemsByCategoryFuture(categoryId);
  }
}