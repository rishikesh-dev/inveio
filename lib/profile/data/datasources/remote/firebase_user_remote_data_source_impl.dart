import 'package:inveio/profile/data/models/user_model.dart';
import 'package:inveio/profile/data/datasources/remote/user_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase implementation of [UserRemoteDataSource].
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  /// Creates a [UserRemoteDataSourceImpl] with the given Firestore and Auth instances.
  UserRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  /// Fetches the user profile from Firestore using the current authenticated user's UID.
  @override
  Future<UserModel?> fetchProfile() async {
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    final data = doc.data();
    return data != null ? UserModel.fromJson(data) : null;
  }

  /// Pushes the given [profile] to Firestore, merging with existing data.
  @override
  Future<void> pushProfile(UserModel profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(profile.toJson(), SetOptions(merge: true));
  }
}
