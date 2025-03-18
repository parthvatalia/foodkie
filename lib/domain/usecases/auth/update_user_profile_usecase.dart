// domain/usecases/auth/update_user_profile_usecase.dart
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/domain/repositories/auth_repository.dart';

class UpdateUserProfileUseCase {
  final AuthRepository _authRepository;

  UpdateUserProfileUseCase(this._authRepository);

  Future<UserModel> execute({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    return await _authRepository.updateUserProfile(
      userId: userId,
      name: name,
      phone: phone,
      profileImage: profileImage,
    );
  }
}