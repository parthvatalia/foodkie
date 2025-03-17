
// domain/usecases/category/update_category_usecase.dart
import 'dart:io';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository _categoryRepository;

  UpdateCategoryUseCase(this._categoryRepository);

  Future<Category> execute({
    required String id,
    String? name,
    String? description,
    File? imageFile,
    int? order,
  }) async {
    return await _categoryRepository.updateCategory(
      id: id,
      name: name,
      description: description,
      imageFile: imageFile,
      order: order,
    );
  }
}