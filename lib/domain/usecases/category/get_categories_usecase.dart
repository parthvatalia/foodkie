// domain/usecases/category/get_categories_usecase.dart
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository _categoryRepository;

  GetCategoriesUseCase(this._categoryRepository);

  Stream<List<Category>> execute() {
    return _categoryRepository.getAllCategories();
  }

  // Add this new method for Future-based retrieval
  Future<List<Category>> executeFuture() async {
    return await _categoryRepository.getAllCategoriesFuture();
  }
}