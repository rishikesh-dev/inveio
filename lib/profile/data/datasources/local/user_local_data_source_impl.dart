import 'package:inveio/profile/data/models/user_model.dart';
import 'package:inveio/profile/data/datasources/local/user_local_data_source.dart';
import 'package:isar_community/isar.dart';


/// Isar-backed implementation of [UserLocalDataSource].
class UserLocalDataSourceImpl extends UserLocalDataSource {
  final Isar _isar;

  /// Creates a [UserLocalDataSourceImpl] with the given Isar instance.
  UserLocalDataSourceImpl({required Isar isar}) : _isar = isar;

  /// Deletes the locally cached profile for the given [uid].
  @override
  Future<void> deleteProfile({required String uid}) async {
    await _isar.writeTxn(() async {
      await _isar.userModels.filter().uidEqualTo(uid).deleteAll();
    });
  }

  /// Retrieves the cached profile for the given [uid].
  @override
  Future<UserModel?> getProfile(String uid) async {
    return await _isar.userModels.getByUid(uid);
  }

  /// Persists the given [user] locally, updating the existing entry if present.
  @override
  Future<void> saveProfile(UserModel user) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.userModels
          .filter()
          .uidEqualTo(user.uid)
          .findFirst();

      if (existing != null) {
        user.isarId = existing.isarId;
      }

      await _isar.userModels.put(user);
    });
  }

  /// Returns a stream that emits the cached profile for the given [uid] on changes.
  @override
  Stream<UserModel?> watchProfile(String uid) {
    return _isar.userModels
        .where()
        .uidEqualTo(uid)
        .watch(fireImmediately: true)
        .map((list) => list.firstOrNull);
  }
}
