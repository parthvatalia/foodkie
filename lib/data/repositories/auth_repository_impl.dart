// data/repositories/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/datasources/local/local_storage.dart';
import 'package:foodkie/data/datasources/remote/auth_remote_source.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource _remoteSource;
  final LocalStorage _localStorage;

  AuthRepositoryImpl(this._remoteSource, this._localStorage);

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
        await _localStorage.saveUser(user);
        await _localStorage.saveRememberMe(true);
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
      await _localStorage.clearUserData();
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
        final localUser = _localStorage.getUser();
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
      return _remoteSource.isAuthenticated() || _localStorage.getUser() != null;
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
      final localUser = _localStorage.getUser();
      if (localUser != null && localUser.id == userId) {
        await _localStorage.saveUser(updatedUser);
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