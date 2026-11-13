/// Shared password conditions reused by every screen that accepts a password
/// (sign-in, sign-up and change password).
class PasswordValidator {
  const PasswordValidator._();

  /// Minimum password length.
  static const int minLength = 8;

  static final RegExp _number = RegExp(r'\d');
  static final RegExp _uppercase = RegExp(r'[A-Z]');
  static final RegExp _special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Whether [value] has at least [minLength] characters.
  static bool hasMinLength(String value) => value.length >= minLength;

  /// Whether [value] contains at least one number.
  static bool hasNumber(String value) => _number.hasMatch(value);

  /// Whether [value] contains at least one uppercase letter.
  static bool hasUppercase(String value) => _uppercase.hasMatch(value);

  /// Whether [value] contains at least one special character.
  static bool hasSpecial(String value) => _special.hasMatch(value);

  /// Requirement checklist for [value] in display order: (label, isMet).
  static List<(String, bool)> checks(String value) {
    return [
      ('At least $minLength characters', hasMinLength(value)),
      ('Includes a number', hasNumber(value)),
      ('Includes an uppercase letter', hasUppercase(value)),
      ('Includes a special character (e.g. !@#\$%)', hasSpecial(value)),
    ];
  }

  /// Validates a password field, returning the first unmet condition.
  static String? validate(
    String? value, {
    String emptyMessage = 'Please enter your password',
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage;
    }
    if (!hasMinLength(value)) {
      return 'Password must be at least $minLength characters';
    }
    if (!hasNumber(value)) {
      return 'Password must include a number';
    }
    if (!hasUppercase(value)) {
      return 'Password must include an uppercase letter';
    }
    if (!hasSpecial(value)) {
      return 'Password must include a special character';
    }
    return null;
  }

  /// Validates a confirm-password field: required and equal to [password].
  static String? validateConfirm(
    String? value,
    String password, {
    String emptyMessage = 'Please enter your password',
  }) {
    if (value == null || value.isEmpty) {
      return emptyMessage;
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
