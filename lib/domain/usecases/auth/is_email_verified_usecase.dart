import 'package:foodkie/domain/repositories/auth_repository.dart';

class IsEmailVerifiedUseCase {
  final AuthRepository _authRepository;

  IsEmailVerifiedUseCase(this._authRepository);

  Future execute() async {
    return await _authRepository.isEmailVerified();
  }
}