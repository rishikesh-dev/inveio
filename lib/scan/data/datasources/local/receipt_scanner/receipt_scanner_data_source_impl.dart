import 'dart:io';

import 'package:inveio/scan/data/datasources/local/receipt_scanner/receipt_scanner_data_source.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/scan_exceptions.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

class ReceiptScannerDataSourceImpl extends ReceiptScannerDataSource {
  final DocumentScanner scannedDocuments;

  ReceiptScannerDataSourceImpl({required this.scannedDocuments});

  @override
  Future<File> scanDocument() async {
    try {
      final result = await scannedDocuments.scanDocument();

      final images = result.images;
      if (images == null || images.isEmpty) {
        // The scanner closed without producing a page: the user cancelled.
        throw const ScanCancelledException();
      }

      final imagePath = images.first;

      final filePath = imagePath.startsWith('file:')
          ? Uri.parse(imagePath).toFilePath()
          : imagePath;

      return File(filePath);
    } on PlatformException catch (error) {
      if (_isScanCancellation(error)) {
        throw const ScanCancelledException();
      }
      throw Exception('Failed to scan document');
    }
  }

  /// Whether [error] means the user closed the system scanner.
  ///
  /// The plugin has no dedicated cancel result or typed exception: on Android
  /// it reports a generic `PlatformException` whose error code is the plugin
  /// tag (shared with real failures) and whose message is `Operation
  /// cancelled`. A cancel-shaped error code is checked first in case a
  /// platform reports one, and the message is only a fallback because that is
  /// the sole cancel signal the plugin currently provides.
  static bool _isScanCancellation(PlatformException error) {
    if (error.code.toLowerCase().contains('cancel')) return true;
    return (error.message ?? '').toLowerCase().contains('cancel');
  }
}
