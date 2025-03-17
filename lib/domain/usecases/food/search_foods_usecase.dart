
// domain/usecases/food/search_foods_usecase.dart
import 'package:foodkie/data/models/food_item_model.dart';
import 'package:foodkie/domain/repositories/food_repository.dart';

class SearchFoodsUseCase {
  final FoodRepository _foodRepository;

  SearchFoodsUseCase(this._foodRepository);

  Future<List<FoodItem>> execute(String query) async {
    return await _foodRepository.searchFoodItems(query);
  }
}