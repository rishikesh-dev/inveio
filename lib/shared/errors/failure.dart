/// Base class for all application failures.
abstract class Failure {
  /// A human-readable error message.
  final String message;

  /// An optional error code for categorizing the failure.
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

/// Failure that occurs during authentication operations.
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// Failure that occurs due to a server-side error.
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Failure that occurs due to a network connectivity issue.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Failure that occurs when the user is not authorized.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.code});
}

/// Failure that occurs when reading or writing to the local cache.
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Failure used for unexpected or generic errors.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});
}
