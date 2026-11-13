import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

/// Repository abstraction for user profile operations.
abstract class UserRepository {
  /// Fetches the user profile from the remote source.
  Future<Either<Failure, UserEntity>> fetchProfile();

  /// Updates the given [user] profile on the remote source.
  Future<Either<Failure, UserEntity>> updateProfile({required UserEntity user});

  /// Returns a stream that emits the user profile for the given [uid] on changes.
  Stream<Either<Failure, UserEntity?>> watchProfile({required String uid});
}
