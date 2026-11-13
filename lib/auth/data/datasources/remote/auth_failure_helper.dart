import 'package:inveio/shared/errors/failure.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Maps Firebase authentication errors to user-friendly [Failure] messages.
class AuthFailureHelper {
  static const _firebaseErrors = {
    // Signup
    'email-already-in-use':
        'This email is already registered. Try signing in instead.',
    'weak-password': 'Password must be at least 8 characters long.',
    'invalid-email': 'Please enter a valid email address.',

    // Login
    'user-not-found': 'Invalid email or password.',
    'wrong-password': 'Invalid email or password.',
    'invalid-credential': 'Invalid email or password.',

    // Account
    'user-disabled': 'This account has been disabled.',
    'requires-recent-login': 'Please sign in again and try again.',
    'credential-already-in-use': 'This account is already linked elsewhere.',
    'account-exists-with-different-credential':
        'An account already exists with a different sign-in method.',

    // System
    'network-request-failed': 'Check your internet connection and try again.',
    'too-many-requests': 'Too many attempts. Please try again later.',
    'operation-not-allowed': 'This sign-in method is currently unavailable.',
  };

  /// Converts a [FirebaseAuthException] into an [AuthFailure] with a user-friendly message.
  static Failure mapFirebaseError(FirebaseAuthException e) {
    final msg =
        _firebaseErrors[e.code] ?? 'Authentication failed. Please try again.';
    if (!_firebaseErrors.containsKey(e.code)) {
      debugPrint('Unknown Firebase auth error: ${e.code} - ${e.message}');
    }
    return AuthFailure(msg, code: e.code);
  }
}
