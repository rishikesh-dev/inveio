part of 'auth_bloc.dart';

/// Base sealed class for all authentication states.
sealed class AuthState extends Equatable {
  const AuthState();

  /// The list of properties used for equality comparison.
  @override
  List<Object?> get props => [];
}

/// State indicating the auth bloc is in its initial state.
final class AuthInitial extends AuthState {}

/// State indicating an authentication operation is in progress.
final class AuthLoading extends AuthState {}

/// State indicating the user is not authenticated.
class AuthUnauthenticated extends AuthState {}

/// State indicating the user has signed in successfully.
final class AuthSignedIn extends AuthState {
  /// The authenticated user entity.
  final UserEntity user;

  /// Creates an [AuthSignedIn] state with the given [user].
  const AuthSignedIn({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State indicating the user has signed out.
final class AuthSignedOut extends AuthState {}

/// State indicating the user profile has been updated.
final class AuthProfileUpdated extends AuthState {
  /// The updated user entity.
  final UserEntity user;

  /// Creates an [AuthProfileUpdated] state with the updated [user].
  const AuthProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State indicating the user's profile photo has been updated.
final class AuthProfilePhotoUpdated extends AuthState {
  /// The user entity with the updated photo.
  final UserEntity user;

  /// Creates an [AuthProfilePhotoUpdated] state with the updated [user].
  const AuthProfilePhotoUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

/// State indicating a password reset email has been sent.
final class AuthPasswordResetSent extends AuthState {}

final class AuthPasswordChanged extends AuthState {}

/// State indicating the user's account has been deleted.
final class AuthAccountDeleted extends AuthState {}

/// State indicating an authentication error has occurred.
final class AuthErrorState extends AuthState {
  /// The error message describing what went wrong.
  final String message;
  final String? code;

  /// Creates an [AuthErrorState] with the given error [message].
  const AuthErrorState({required this.message, this.code});

  @override
  List<Object?> get props => [message];
}
