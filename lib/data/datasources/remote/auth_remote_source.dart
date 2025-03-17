// data/datasources/remote/auth_remote_source.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkie/core/constants/app_constants.dart';
import 'package:foodkie/core/enums/app_enums.dart';
import 'package:foodkie/core/constants/error_constants.dart';
import 'package:foodkie/data/models/user_model.dart';

class AuthRemoteSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current authenticated user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }

  // Register a new user
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
  }) async {
    try {
      // Create authentication account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception(ErrorConstants.unknownError);
      }

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Create user document in Firestore
      final userId = userCredential.user!.uid;
      final now = DateTime.now();

      final userModel = UserModel(
        id: userId,
        name: name,
        email: email,
        role: role,
        phone: phone,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception(ErrorConstants.emailInUse);
        case 'invalid-email':
          throw Exception(ErrorConstants.invalidEmail);
        case 'weak-password':
          throw Exception(ErrorConstants.weakPassword);
        default:
          throw Exception(e.message ?? ErrorConstants.unknownError);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Login user
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception(ErrorConstants.accountNotFound);
      }

      // Get user data from Firestore
      final userId = userCredential.user!.uid;
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception(ErrorConstants.accountNotFound);
      }

      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception(ErrorConstants.accountNotFound);
        case 'wrong-password':
          throw Exception(ErrorConstants.wrongCredentials);
        case 'invalid-email':
          throw Exception(ErrorConstants.invalidEmail);
        case 'user-disabled':
          throw Exception(ErrorConstants.userDisabled);
        case 'too-many-requests':
          throw Exception(ErrorConstants.tooManyRequests);
        default:
          throw Exception(e.message ?? ErrorConstants.unknownError);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Logout user
  Future<void> logoutUser() async {
    await _firebaseAuth.signOut();
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception(ErrorConstants.invalidEmail);
        case 'user-not-found':
          throw Exception(ErrorConstants.accountNotFound);
        default:
          throw Exception(e.message ?? ErrorConstants.unknownError);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get user profile from Firestore
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);

      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        throw Exception(ErrorConstants.accountNotFound);
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      final updatedUser = user.copyWith(
        name: name ?? user.name,
        phone: phone ?? user.phone,
        profileImage: profileImage ?? user.profileImage,
        updatedAt: DateTime.now(),
      );

      await userRef.update(updatedUser.toJson());

      return updatedUser;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Change user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception(ErrorConstants.sessionExpired);
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw Exception(ErrorConstants.wrongCredentials);
        case 'weak-password':
          throw Exception(ErrorConstants.weakPassword);
        case 'requires-recent-login':
          throw Exception(ErrorConstants.sessionExpired);
        default:
          throw Exception(e.message ?? ErrorConstants.unknownError);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Verify email
  Future<bool> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception(ErrorConstants.sessionExpired);
      }

      await user.reload();
      return user.emailVerified;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw Exception(ErrorConstants.sessionExpired);
      }

      await user.sendEmailVerification();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}