import 'package:inveio/profile/data/models/user_model.dart';

/// Local data source for user profile caching and persistence.
abstract class UserLocalDataSource {
  /// Retrieves the cached profile for the given [uid].
  Future<UserModel?> getProfile(String uid);

  /// Returns a stream that emits the cached profile for the given [uid] on changes.
  Stream<UserModel?> watchProfile(String uid);

  /// Persists the given [profile] locally.
  Future<void> saveProfile(UserModel profile);

  /// Deletes the locally cached profile for the given [uid].
  Future<void> deleteProfile({required String uid});
}
