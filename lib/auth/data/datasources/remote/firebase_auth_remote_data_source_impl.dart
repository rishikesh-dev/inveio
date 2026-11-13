import 'package:inveio/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:inveio/auth/data/datasources/remote/auth_failure_helper.dart';
import 'package:inveio/profile/data/models/user_model.dart';
import 'package:inveio/shared/errors/exceptions.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase implementation of [AuthRemoteDataSource] using Firebase Auth and Google Sign-In.
class FirebaseAuthRemoteDataSourceImpl extends AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Creates a [FirebaseAuthRemoteDataSourceImpl] with the required Firebase and Google services.
  FirebaseAuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  }) : _googleSignIn = googleSignIn,
       _firebaseAuth = firebaseAuth;

  /// Checks whether a user is currently authenticated.
  @override
  Future<void> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthFailure('No authenticated user');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on Failure {
      rethrow;
    } catch (e) {
      throw Exception(
        'Unable to process your request right now. Please try again later.',
      );
    }
  }

  /// Creates a new user via Firebase email/password authentication and returns the user model with the assigned UID.
  @override
  Future<UserModel> createUser({
    required UserModel userDetails,
    required String password,
  }) async {
    try {
      final auth = await _firebaseAuth.createUserWithEmailAndPassword(
        email: userDetails.email,
        password: password,
      );

      final user = auth.user;

      if (user == null) {
        throw Exception('Failed to create account');
      }
      return userDetails.copyWith(uid: user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e is FirebaseAuthException) {
        throw _handleAuthException(e);
      }
      final cause = (e as dynamic).cause;
      if (cause is FirebaseAuthException) {
        throw _handleAuthException(cause);
      }
      throw Exception('Unable to create your account. Please try again later.');
    }
  }

  /// Signs in an existing user with email and password.
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(
        'Unable to process your request right now. Please try again later.',
      );
    }
  }

  /// Sends a password reset email to the given address.
  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(
        'Unable to send password reset email. Please try again later.',
      );
    }
  }

  /// Signs out from both Google and Firebase authentication.
  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Deletes the current user's account and signs out from Google.
  @override
  Future<void> deleteUserAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw const AuthFailure('No authenticated user');
    try {
      await user.delete();
      await _googleSignIn.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(
        'Unable to process your request right now. Please try again later.',
      );
    }
  }

  /// Signs in with Google and returns the user model from the authenticated account.
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final user = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = user.user;

      if (firebaseUser == null) {
        throw Exception('Google sign in failed');
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phone: firebaseUser.phoneNumber,
        isPro: false,
        createdAt: firebaseUser.metadata.creationTime,
      );

      return userModel;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthCancelledException();
      }
      throw Exception('Google sign-in failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception(
        'Unable to process your request right now. Please try again later. $e',
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw const AuthFailure('No authenticated user');
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException {
      rethrow;
    }
  }
}

Never _handleAuthException(FirebaseAuthException e) {
  throw AuthFailureHelper.mapFirebaseError(e);
}
