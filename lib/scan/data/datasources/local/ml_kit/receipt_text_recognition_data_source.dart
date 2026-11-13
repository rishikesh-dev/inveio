import 'dart:io';

import 'package:inveio/scan/domain/entities/parsed_receipt.dart';

/// Performs text recognition (OCR) on a scanned receipt image and parses
/// the recognized text into structured fields.
abstract class ReceiptTextRecognitionDataSource {
  /// Extracts structured receipt data (amount, vendor, date, GSTIN) from
  /// the given scanned [image].
  Future<ParsedReceipt> extractReceipt(File image);
}
