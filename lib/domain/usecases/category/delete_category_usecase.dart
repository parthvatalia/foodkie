// domain/usecases/category/delete_category_usecase.dart
import 'package:foodkie/domain/repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository _categoryRepository;

  DeleteCategoryUseCase(this._categoryRepository);

  Future<void> execute(String id) async {
    await _categoryRepository.deleteCategory(id);
  }
}