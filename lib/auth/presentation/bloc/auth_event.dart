part of 'auth_bloc.dart';

/// Base sealed class for all authentication events.
sealed class AuthEvent extends Equatable {
  /// Creates an [AuthEvent].
  const AuthEvent();

  /// The list of properties used for equality comparison.
  @override
  List<Object?> get props => [];
}

/// Event to clear the current auth state back to initial.
final class ClearAuthEvent extends AuthEvent {
  /// Creates a [ClearAuthEvent].
  const ClearAuthEvent();
}

/// Event to initiate sign-in with Google.
final class SignInWithGoogle extends AuthEvent {
  /// Creates a [SignInWithGoogle] event.
  const SignInWithGoogle();
}

/// Event to sign up a new user with email and password.
final class SignUpWithEmail extends AuthEvent {
  /// The user's full name.
  final String name;

  /// The user's email address.
  final String email;

  /// The user's chosen password.
  final String password;

  /// Creates a [SignUpWithEmail] event with the required registration details.
  const SignUpWithEmail({
    required this.name,
    required this.email,
    required this.password,
  });
}

/// Event to sign in with email and password.
final class SignInWithEmail extends AuthEvent {
  /// The user's email address.
  final String email;

  /// The user's password.
  final String password;

  /// Creates a [SignInWithEmail] event with the given credentials.
  const SignInWithEmail({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign the current user out.
final class SignOut extends AuthEvent {
  /// The UID of the user to sign out.
  final String uid;

  /// Creates a [SignOut] event for the given [uid].
  const SignOut({required this.uid});
}

/// Event to delete the current user's account.
final class DeleteAccount extends AuthEvent {
  /// Creates a [DeleteAccount] event.
  const DeleteAccount();
}

/// Event to request a password reset email.
final class ResetPasswordEvent extends AuthEvent {
  /// The email address to send the reset link to.
  final String email;

  /// Creates a [ResetPasswordEvent] for the given [email].
  const ResetPasswordEvent({required this.email});
}

final class ChangePasswordEvent extends AuthEvent {
  /// The user's current password.
  final String currentPassword;

  /// The new password to set.
  final String newPassword;

  /// Creates a [ChangePasswordEvent] with the current and new passwords.
  const ChangePasswordEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

/// Event to check whether a user is currently authenticated.
final class CheckAuthStatus extends AuthEvent {
  /// Creates a [CheckAuthStatus] event.
  const CheckAuthStatus();
}
