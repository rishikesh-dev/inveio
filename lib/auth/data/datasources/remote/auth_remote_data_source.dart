import 'package:inveio/profile/data/models/user_model.dart';

/// Abstract interface for remote authentication operations.
abstract class AuthRemoteDataSource {
  /// Creates a new user account with the given details and password.
  Future<UserModel> createUser({
    required UserModel userDetails,
    required String password,
  });

  /// Signs in with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sends a password reset email.
  Future<void> resetPassword({required String email});

  /// Signs the current user out.
  Future<void> signOut();

  /// Deletes the current user's account.
  Future<void> deleteUserAccount();

  /// Retrieves the currently authenticated user.
  Future<void> getCurrentUser();

  /// Signs in with Google authentication.
  Future<UserModel> signInWithGoogle();
  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
