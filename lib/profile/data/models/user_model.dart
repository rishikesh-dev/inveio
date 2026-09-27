import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar_community/isar.dart';
part 'user_model.g.dart';

/// Isar collection model for persisting user data locally.
@collection
class UserModel {
  /// Auto-incremented Isar ID.
  Id isarId = Isar.autoIncrement;

  /// Firebase Auth / Firestore UID.
  @Index(unique: true)
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

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.isPro,
    required this.createdAt,
  });

  /// Creates a copy of this [UserModel] with the given fields replaced.
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    bool? isPro,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      isPro: isPro ?? this.isPro,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a [UserModel] from a Firestore JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isPro: json['isPro'] as bool? ?? false,
      createdAt: (json['createdAt'] as firestore.Timestamp?)?.toDate(),
    );
  }

  /// Converts this model to a Firestore-compatible JSON map.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'isPro': isPro,
      'createdAt': createdAt,
    };
  }

  /// Converts this model to a map of only updatable fields.
  Map<String, dynamic> toUpdateJson() {
    return {'name': name, 'phone': phone, 'photoUrl': photoUrl};
  }

  /// Creates a [UserModel] from a [UserEntity].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      isPro: entity.isPro,
      createdAt: entity.createdAt,
    );
  }

  /// Converts this model to a [UserEntity].
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      photoUrl: photoUrl,
      isPro: isPro,
      createdAt: createdAt,
    );
  }
}
