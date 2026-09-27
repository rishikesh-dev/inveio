import 'package:inveio/profile/data/models/user_model.dart';

/// Remote data source for user profile operations.
abstract interface class UserRemoteDataSource {
  /// Fetches the current user's profile from the remote backend.
  Future<UserModel?> fetchProfile();

  /// Pushes the given [profile] to the remote backend.
  Future<void> pushProfile(UserModel profile);
}
