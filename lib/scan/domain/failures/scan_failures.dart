import 'package:inveio/shared/errors/failure.dart';

/// The user backed out of the system scanner/camera.
///
/// This is not an error: the caller resets to its idle state without showing
/// a message.
class ScanCancelledFailure extends Failure {
  /// Creates a [ScanCancelledFailure].
  const ScanCancelledFailure() : super('Scan cancelled');
}
