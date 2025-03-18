// domain/usecases/auth/is_authenticated_usecase.dart
import 'package:foodkie/domain/repositories/auth_repository.dart';

class IsAuthenticatedUseCase {
  final AuthRepository _authRepository;

  IsAuthenticatedUseCase(this._authRepository);

  bool execute() {
    return _authRepository.isAuthenticated();
  }
}