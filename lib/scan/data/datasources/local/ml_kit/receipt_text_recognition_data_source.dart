import 'dart:io';

import 'package:inveio/scan/data/models/scan_receipt_model.dart';

/// Performs text recognition (OCR) on a scanned receipt image and parses
/// the recognized text into structured fields.
abstract class ReceiptTextRecognitionDataSource {
  /// Extracts structured receipt data (amount, vendor, date, GSTIN) from
  /// the given scanned [image].
  Future<ScanReceiptModel> extractReceipt(File image);
}
