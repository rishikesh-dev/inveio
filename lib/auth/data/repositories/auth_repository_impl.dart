import 'dart:async';
import 'dart:io';
import 'package:inveio/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:inveio/profile/data/models/user_model.dart';
import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/auth/domain/repositories/auth_repository.dart';
import 'package:inveio/shared/errors/exceptions.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/profile/data/datasources/remote/user_remote_data_source.dart';
import 'package:inveio/profile/data/datasources/local/user_local_data_source.dart'
    show UserLocalDataSource;
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';

/// Implementation of [AuthRepository] that coordinates remote and local data sources.
class AuthRepositoryImpl extends AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final UserLocalDataSource _userLocalDataSource;
  final UserRemoteDataSource _userRemoteDataSource;

  /// Creates an [AuthRepositoryImpl] with the required data sources.
  AuthRepositoryImpl({
    required AuthRemoteDataSource authRemoteDataSource,
    required UserLocalDataSource userLocalDataSource,
    required UserRemoteDataSource userRemoteDataSource,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _userLocalDataSource = userLocalDataSource,
       _userRemoteDataSource = userRemoteDataSource;

  /// Creates a new user, pushes the profile remotely, and saves it locally.
  @override
  Future<Either<Failure, UserEntity>> createUser({
    required UserEntity userDetails,
    required String password,
  }) async {
    try {
      final createdUser = await _authRemoteDataSource.createUser(
        userDetails: UserModel.fromEntity(userDetails),
        password: password,
      );
      await _userRemoteDataSource.pushProfile(createdUser);
      await _userLocalDataSource.saveProfile(createdUser);
      return right(createdUser.toEntity());
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Signs in with email and password, then fetches and caches the user profile.
  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _authRemoteDataSource.signInWithEmail(
        email: email,
        password: password,
      );
      final remoteUser = await _userRemoteDataSource.fetchProfile();
      if (remoteUser == null) {
        return left(const AuthFailure('User profile not found'));
      }
      await _userLocalDataSource.saveProfile(remoteUser);
      return right(remoteUser.toEntity());
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Signs in with Google, then fetches and caches the user profile.
  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _authRemoteDataSource.signInWithGoogle();
      var remoteUser = await _userRemoteDataSource.fetchProfile();

      if (remoteUser == null) {
        await _userRemoteDataSource.pushProfile(googleUser);
        remoteUser = googleUser;
      }

      await _userLocalDataSource.saveProfile(remoteUser);
      return right(remoteUser.toEntity());
    } on AuthCancelledException {
      return left(const AuthCancelledFailure());
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Returns the currently authenticated user's profile.
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      await _authRemoteDataSource.getCurrentUser();
      final user = await _userRemoteDataSource.fetchProfile();
      if (user == null) {
        return left(const AuthFailure('User profile not found'));
      }

      return right(user.toEntity());
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Sends a password reset email to the given address.
  @override
  Future<Either<Failure, void>> resetPassword({required String email}) async {
    try {
      return right(await _authRemoteDataSource.resetPassword(email: email));
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on PlatformException catch (e) {
      return left(
        AuthFailure(e.message ?? 'Too many attempts. Try again later.'),
      );
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Deletes the user's account remotely and cleans up local profile data.
  @override
  Future<Either<Failure, void>> deleteUserAccount() async {
    try {
      final user = await _userRemoteDataSource.fetchProfile();
      if (user == null || user.uid == null || user.uid!.isEmpty) {
        return left(const AuthFailure('User profile not found'));
      }
      final id = user.uid!;
      await _authRemoteDataSource.deleteUserAccount();
      await _userLocalDataSource.deleteProfile(uid: id);
      return right(null);
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Signs the user out and removes the local profile for the given [uid].
  @override
  Future<Either<Failure, void>> signOut({required String uid}) async {
    try {
      await _userLocalDataSource.deleteProfile(uid: uid);
      return right(await _authRemoteDataSource.signOut());
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return right(
        await _authRemoteDataSource.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
    } on TimeoutException {
      return left(const NetworkFailure('Connection timed out'));
    } on SocketException catch (e) {
      return left(NetworkFailure(e.message));
    } on PlatformException catch (e) {
      return left(
        AuthFailure(e.message ?? 'Too many attempts. Try again later.'),
      );
    } on Failure catch (e) {
      return left(e);
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification({required String email}) {
    throw UnimplementedError();
  }
}
