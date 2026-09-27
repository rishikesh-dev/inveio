import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/profile/data/models/user_model.dart';
import 'package:inveio/profile/data/datasources/remote/user_remote_data_source.dart';
import 'package:inveio/profile/data/datasources/local/user_local_data_source.dart';
import 'package:inveio/profile/domain/repositories/user_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Implementation of [UserRepository] that coordinates remote and local data sources.
class UserRepositoryImpl extends UserRepository {
  final UserRemoteDataSource _userRemoteDataSource;
  final UserLocalDataSource _userLocalDataSource;

  /// Creates a [UserRepositoryImpl] with the given remote and local data sources.
  UserRepositoryImpl({
    required UserRemoteDataSource userRemoteDataSource,
    required UserLocalDataSource userLocalDataSource,
  }) : _userRemoteDataSource = userRemoteDataSource,
       _userLocalDataSource = userLocalDataSource;
  /// Fetches the user profile from the remote source and caches it locally.
  @override
  Future<Either<Failure, UserEntity>> fetchProfile() async {
    try {
      final user = await _userRemoteDataSource.fetchProfile();
      if (user == null) return left(const AuthFailure('Profile not found'));
      await _userLocalDataSource.saveProfile(user);
      return right(user.toEntity());
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Updates the user profile on the remote source and refreshes the local cache.
  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required UserEntity user,
  }) async {
    try {
      final model = UserModel.fromEntity(user);
      await _userRemoteDataSource.pushProfile(model);
      await _userLocalDataSource.saveProfile(model);
      return right(model.toEntity());
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  /// Returns a stream of the user profile for the given [uid], sourced from local cache.
  @override
  Stream<Either<Failure, UserEntity>> watchProfile({required String uid}) {
    return _userLocalDataSource
        .watchProfile(uid)
        .map(
          (user) => user == null
              ? left(const AuthFailure('Profile not found'))
              : right(user.toEntity()),
        );
  }
}
