// domain/usecases/auth/login_usecase.dart
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<UserModel> execute({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    return await _authRepository.loginUser(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );
  }
}