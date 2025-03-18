// domain/usecases/category/get_categories_future_usecase.dart
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class GetCategoriesFutureUseCase {
  final CategoryRepository _categoryRepository;

  GetCategoriesFutureUseCase(this._categoryRepository);

  Future<List<Category>> execute() async {
    return await _categoryRepository.getAllCategoriesFuture();
  }
}