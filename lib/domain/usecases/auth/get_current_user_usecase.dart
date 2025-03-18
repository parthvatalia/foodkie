// domain/usecases/auth/get_current_user_usecase.dart
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<UserModel?> execute() async {
    return await _authRepository.getCurrentUser();
  }
}