import 'package:foodkie/domain/repositories/auth_repository.dart';

class ResendVerificationEmailUseCase {
  final AuthRepository _authRepository;

  ResendVerificationEmailUseCase(this._authRepository);

  Future execute() async {
    await _authRepository.resendVerificationEmail();
  }
}