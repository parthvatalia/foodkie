// domain/usecases/category/reorder_categories_usecase.dart
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class ReorderCategoriesUseCase {
  final CategoryRepository _categoryRepository;

  ReorderCategoriesUseCase(this._categoryRepository);

  Future<void> execute(List<Category> categories) async {
    await _categoryRepository.reorderCategories(categories);
  }
}