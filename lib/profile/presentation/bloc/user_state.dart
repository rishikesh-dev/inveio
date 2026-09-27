part of 'user_bloc.dart';

/// Base state for user-related BLoC states.
sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

/// Initial state before any user event is processed.
final class UserInitial extends UserState {}

/// State representing a successfully loaded signed-in user.
final class UserSignedState extends UserState {
  /// The loaded user entity.
  final UserEntity user;
  const UserSignedState({required this.user});
}

/// State representing a successfully updated user.
final class UserUpdated extends UserState {
  /// The updated user entity.
  final UserEntity user;
  const UserUpdated({required this.user});
}

/// State representing a user-related error.
final class UserErrorState extends UserState {
  /// The error message describing the failure.
  final String message;
  const UserErrorState({required this.message});
}

/// State representing an ongoing user loading operation.
final class UserLoading extends UserState {}
