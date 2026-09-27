import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

/// Abstract repository for authentication operations.
abstract class AuthRepository {
  /// Creates a new user account.
  Future<Either<Failure, UserEntity>> createUser({
    required UserEntity userDetails,
    required String password,
  });

  /// Signs in with email and password.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> sendEmailVerification({required String email});

  /// Sends a password reset email.
  Future<Either<Failure, void>> resetPassword({required String email});
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Signs the user out.
  Future<Either<Failure, void>> signOut({required String uid});

  /// Deletes the current user's account.
  Future<Either<Failure, void>> deleteUserAccount();

  /// Returns the currently authenticated user.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Signs in with Google authentication.
  Future<Either<Failure, UserEntity>> signInWithGoogle();
}
