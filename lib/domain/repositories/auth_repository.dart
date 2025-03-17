// domain/repositories/auth_repository.dart
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> loginUser({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  });

  Future<void> logoutUser();

  Future<void> forgotPassword(String email);

  Future<UserModel?> getCurrentUser();

  bool isAuthenticated();

  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<bool> isEmailVerified();

  Future<void> resendVerificationEmail();
}