/// Parameters required for user registration.
class UserDetailsParams {
  /// The user's full name.
  final String name;

  /// The user's email address.
  final String email;

  /// The user's phone number (optional).
  final String? phone;

  /// The user's photo URL (optional).
  final String? photoUrl;

  /// The user's chosen password.
  final String password;

  /// Creates a [UserDetailsParams] with the required registration fields.
  UserDetailsParams({
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    required this.password,
  });
}
