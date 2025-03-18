// domain/usecases/category/search_categories_usecase.dart
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class SearchCategoriesUseCase {
  final CategoryRepository _categoryRepository;

  SearchCategoriesUseCase(this._categoryRepository);

  Future<List<Category>> execute(String query) async {
    return await _categoryRepository.searchCategories(query);
  }
}