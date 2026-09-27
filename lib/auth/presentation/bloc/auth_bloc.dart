import 'package:inveio/auth/domain/repositories/auth_repository.dart';
import 'package:inveio/auth/domain/usecases/params/user_details_params.dart';
import 'package:inveio/auth/domain/usecases/sign_up_with_email_use_case.dart';
import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// BLoC that manages authentication state and events.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  /// Repository for authentication operations.
  final AuthRepository _authRepository;
  


  /// Use case for signing up with email and password.
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;

  /// Creates an [AuthBloc] with the required dependencies.
  AuthBloc({
    required AuthRepository authRepository,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
  }) : _authRepository = authRepository,
       _signUpWithEmailUseCase = signUpWithEmailUseCase,
       super(AuthInitial()) {
    on<SignUpWithEmail>(_onSignUpWithEmail);
    on<SignInWithGoogle>(_onSignInWithGoogle);
    on<SignInWithEmail>(_onSignInWithEmail);
    on<ResetPasswordEvent>(_onResetPassword);
    on<ChangePasswordEvent>(_onChangePassword);
    on<SignOut>(_onSignOut);
    on<DeleteAccount>(_onDeleteAccount);
    on<ClearAuthEvent>(_onClearAuth);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrUser = await _signUpWithEmailUseCase(
      params: UserDetailsParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    failureOrUser.fold(
      (failure) =>
          emit(AuthErrorState(message: failure.message, code: failure.code)),
      (user) => emit(AuthSignedIn(user: user)),
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrUser = await _authRepository.signInWithGoogle();
    failureOrUser.fold(
      (failure) =>
          emit(AuthErrorState(message: failure.message, code: failure.code)),
      (user) => emit(AuthSignedIn(user: user)),
    );
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrUser = await _authRepository.signInWithEmail(
      email: event.email,
      password: event.password,
    );
    failureOrUser.fold(
      (failure) =>
          emit(AuthErrorState(message: failure.message, code: failure.code)),
      (user) => emit(AuthSignedIn(user: user)),
    );
  }

  Future<void> _onResetPassword(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrUser = await _authRepository.resetPassword(
      email: event.email,
    );
    failureOrUser.fold(
      (failure) =>
          emit(AuthErrorState(message: failure.message, code: failure.code)),
      (_) => emit(AuthPasswordResetSent()),
    );
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) =>
          emit(AuthErrorState(message: failure.message, code: failure.code)),
      (user) => emit(AuthPasswordChanged()),
    );
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final failureOrUser = await _authRepository.signOut(uid: event.uid);
    failureOrUser.fold(
      (failure) =>
          emit(AuthErrorState(message: failure.message, code: failure.code)),
      (_) => emit(AuthSignedOut()),
    );
  }

  Future<void> _onDeleteAccount(
    DeleteAccount event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final failureOrDeleted = await _authRepository.deleteUserAccount();
    failureOrDeleted.fold(
      (failure) =>
          emit(AuthErrorState(message: failure.message, code: failure.code)),
      (_) => emit(AuthAccountDeleted()),
    );
  }

  void _onClearAuth(ClearAuthEvent event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthSignedIn(user: user)),
    );
  }
}
