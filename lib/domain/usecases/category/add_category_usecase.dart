// domain/usecases/category/add_category_usecase.dart
import 'dart:io';
import 'package:foodkie/data/models/category_model.dart';
import 'package:foodkie/domain/repositories/category_repository.dart';

class AddCategoryUseCase {
  final CategoryRepository _categoryRepository;

  AddCategoryUseCase(this._categoryRepository);

  Future<Category> execute({
    required String name,
    required String description,
    File? imageFile,
    int? order,
  }) async {
    return await _categoryRepository.addCategory(
      name: name,
      description: description,
      imageFile: imageFile,
      order: order,
    );
  }
}