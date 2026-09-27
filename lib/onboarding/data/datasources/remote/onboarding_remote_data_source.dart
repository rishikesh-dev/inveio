import 'package:inveio/onboarding/data/models/onboarding_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Remote data source for onboarding data backed by Cloud Firestore.
class OnboardingRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Creates an [OnboardingRemoteDataSource] with the given Firestore and Auth instances.
  OnboardingRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  /// Saves the [data] to the current user's onboarding document in Firestore.
  Future<void> saveOnboarding(OnboardingModel data) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('onboarding')
        .doc('details')
        .set(data.toJson());
  }

  // Fetches the onboarding data for the current user from Firestore.
  // OnboardingRemoteDataSource
  Future<OnboardingModel?> fetchOnboarding(String uid) async {
    final docSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('onboarding')
        .doc('details')
        .get();

    if (!docSnapshot.exists) return null;
    return OnboardingModel.fromJson(docSnapshot.data()!);
  }
}
