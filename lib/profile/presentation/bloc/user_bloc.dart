import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/profile/domain/repositories/user_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_event.dart';
part 'user_state.dart';

/// BLoC that manages user profile state.
class UserBloc extends Bloc<UserEvent, UserState> {
  /// The repository used for profile data operations.
  final UserRepository repository;

  /// The authentication BLoC for coordinating auth-related events.
  final AuthBloc authBloc;

  /// Creates a [UserBloc] with the given [repository] and [authBloc].
  UserBloc({required this.repository, required this.authBloc})
    : super(UserInitial()) {
    on<FetchProfileEvent>(_onFetchUserEvent);
    on<UpdateProfileEvent>(_onUpdateUserEvent);
  }

  Future<void> _onFetchUserEvent(
    FetchProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    final result = await repository.fetchProfile();
    result.fold(
      (failure) => emit(UserErrorState(message: failure.message)),
      (user) => emit(UserSignedState(user: user)),
    );
  }

  Future<void> _onUpdateUserEvent(
    UpdateProfileEvent event,
    Emitter<UserState> emit,
  ) async {
    final result = await repository.updateProfile(user: event.user);
    result.fold(
      (failure) => emit(UserErrorState(message: failure.message)),
      (user) => emit(UserUpdated(user: user)),
    );
  }
}
