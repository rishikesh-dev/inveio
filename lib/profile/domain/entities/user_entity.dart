import 'package:equatable/equatable.dart';

/// Core entity representing an application user.
class UserEntity extends Equatable {
  /// Local database ID.
  final int? id;

  /// Firebase Auth / Firestore UID.
  final String? uid;

  /// Display name of the user.
  final String name;

  /// Email address of the user.
  final String email;

  /// Optional phone number.
  final String? phone;

  /// URL to the user's profile photo.
  final String? photoUrl;

  /// Whether the user has a pro subscription.
  final bool isPro;

  /// Timestamp when the user account was created.
  final DateTime? createdAt;

  const UserEntity({
    this.id,
    this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.isPro = false,
    this.createdAt,
  });
  @override
  List<Object?> get props => [
    id,
    uid,
    name,
    email,
    phone,
    photoUrl,
    isPro,
    createdAt,
  ];
}
