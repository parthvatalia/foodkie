// domain/usecases/category/get_category_by_id_usecase.dart
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class GetCategoryByIdUseCase {
  final CategoryRepository _categoryRepository;

  GetCategoryByIdUseCase(this._categoryRepository);

  Future<Category?> execute(String categoryId) async {
    return await _categoryRepository.getCategoryById(categoryId);
  }
}