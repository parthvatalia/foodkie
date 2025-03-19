// presentation/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/data/models/user_model.dart';
import 'package:foodkie/domain/usecases/auth/change_password_usecase.dart';
import 'package:foodkie/domain/usecases/auth/forgot_password_usecase.dart';
import 'package:foodkie/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:foodkie/domain/usecases/auth/is_authenticated_usecase.dart';
import 'package:foodkie/domain/usecases/auth/login_usecase.dart';
import 'package:foodkie/domain/usecases/auth/logout_usecase.dart';
import 'package:foodkie/domain/usecases/auth/register_usecase.dart';
import 'package:foodkie/domain/usecases/auth/update_user_profile_usecase.dart';

import '../../core/constants/route_constants.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthProvider with ChangeNotifier {
  final LoginUseCase? loginUseCase;
  final RegisterUseCase? registerUseCase;
  final LogoutUseCase? logoutUseCase;
  final GetCurrentUserUseCase? getCurrentUserUseCase;
  final IsAuthenticatedUseCase? isAuthenticatedUseCase;
  final ForgotPasswordUseCase? forgotPasswordUseCase;
  final ChangePasswordUseCase? changePasswordUseCase;
  final UpdateUserProfileUseCase? updateUserProfileUseCase;

  AuthProvider({
    this.loginUseCase,
    this.registerUseCase,
    this.logoutUseCase,
    this.getCurrentUserUseCase,
    this.isAuthenticatedUseCase,
    this.forgotPasswordUseCase,
    this.changePasswordUseCase,
    this.updateUserProfileUseCase,
  });

  UserModel? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  UserModel? get user => _user;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isManager => _user?.role == UserRole.manager;
  bool get isWaiter => _user?.role == UserRole.waiter;
  bool get isKitchenStaff => _user?.role == UserRole.kitchen;

  // Initialize by checking if user is already logged in
  Future<void> initialize() async {
    try {
      _setLoading(true);

      if (isAuthenticatedUseCase != null && isAuthenticatedUseCase!.execute()) {
        final user = await getCurrentUserUseCase?.execute();
        if (user != null) {
          _user = user;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await loginUseCase?.execute(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        return true;
      }

      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final user = await registerUseCase?.execute(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );

      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        return true;
      }



      return false;
    } catch (e) {
      print(e);
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout(BuildContext context) async {
    try {
      _setLoading(true);
      await logoutUseCase?.execute();
      _user = null;
      _status = AuthStatus.unauthenticated;
      Navigator.of(context).pushReplacementNamed(RouteConstants.splash);

    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();
      await forgotPasswordUseCase?.execute(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change Password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      await changePasswordUseCase?.execute(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update Profile
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updatedUser = await updateUserProfileUseCase?.execute(
        userId: userId,
        name: name,
        phone: phone,
        profileImage: profileImage,
      );

      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if the user's email is verified
  Future<bool> isEmailVerified() async {
    try {
      _setLoading(true);
      _clearError();

      // This would typically call a use case like IsEmailVerifiedUseCase
      // Since that's not available, we'll simulate it with a delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real implementation, this would check with Firebase Auth
      // For now, we'll always return false to keep the verification screen active
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend verification email to the current user
  Future<bool> resendVerificationEmail() async {
    try {
      _setLoading(true);
      _clearError();

      // This would typically call a use case like ResendVerificationEmailUseCase
      // Since that's not available, we'll simulate it with a delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real implementation, this would use Firebase Auth to resend the email
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper Methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}