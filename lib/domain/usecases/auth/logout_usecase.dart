// domain/usecases/auth/logout_usecase.dart
import 'package:foodkie/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<void> execute() async {
    await _authRepository.logoutUser();
  }
}