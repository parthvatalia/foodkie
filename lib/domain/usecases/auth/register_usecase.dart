// domain/usecases/auth/register_usecase.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<UserModel> execute({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    return await _authRepository.registerUser(
      email: email,
      password: password,
      name: name,
      role: role,
      phone: phone,
    );
  }
}