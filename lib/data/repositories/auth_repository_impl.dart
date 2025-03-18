// data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/datasources/local/local_storage.dart';
import 'package:foodkie/data/datasources/remote/auth_remote_source.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _remoteSource;

  AuthRepositoryImpl(this._remoteSource);

  @override
  Future<UserModel> loginUser({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final user = await _remoteSource.loginUser(
        email: email,
        password: password,
      );

      // Save user data to local storage if remember me is checked
      if (rememberMe) {
        await LocalStorage.saveUser(user);
        await LocalStorage.saveRememberMe(true);
      }

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final user = await _remoteSource.registerUser(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );

      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      await _remoteSource.logoutUser();
      await LocalStorage.clearUserData();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteSource.forgotPassword(email);
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Check if user is authenticated
      final authUser = _remoteSource.getCurrentUser();
      if (authUser == null) {
        // Try to get user from local storage
        final localUser = LocalStorage.getUser();
        return localUser;
      }

      // Get user profile from Firestore
      final user = await _remoteSource.getUserProfile(authUser.uid);
      return user;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  bool isAuthenticated() {
    try {
      return _remoteSource.isAuthenticated() || LocalStorage.getUser() != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final updatedUser = await _remoteSource.updateUserProfile(
        userId: userId,
        name: name,
        phone: phone,
        profileImage: profileImage,
      );

      // Update user in local storage if exists
      final localUser = LocalStorage.getUser();
      if (localUser != null && localUser.id == userId) {
        await LocalStorage.saveUser(updatedUser);
      }

      return updatedUser;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      return await _remoteSource.isEmailVerified();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      await _remoteSource.resendVerificationEmail();
    } catch (e) {
      throw e.toString();
    }
  }
}
