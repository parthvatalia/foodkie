// domain/usecases/auth/forgot_password_usecase.dart
import 'package:foodkie/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  Future<void> execute(String email) async {
    await _authRepository.forgotPassword(email);
  }
}