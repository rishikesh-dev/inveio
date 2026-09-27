part of 'user_bloc.dart';

/// Base event for user-related BLoC events.
sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to fetch the user profile.
class FetchProfileEvent extends UserEvent {
  @override
  List<Object> get props => [];
}

/// Event triggered to update the user profile with new data.
class UpdateProfileEvent extends UserEvent {
  /// The updated user entity.
  final UserEntity user;

  const UpdateProfileEvent({required this.user});
  @override
  List<Object> get props => [];
}
