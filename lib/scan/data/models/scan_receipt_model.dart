import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:equatable/equatable.dart';

class ScanReceiptModel extends Equatable {
  /// Full raw OCR/Gemini text output, kept for debugging bad parses.

  final String rawText;

  /// Extraction confidence, used to decide whether to highlight fields
  /// for user review. ML Kit path: heuristic. Gemini path: model-reported.

  final ScanConfidence confidence;

  /// Parsed total amount, if found. Null if extraction failed.

  final double? amount;

  /// Parsed vendor/business name, if found.
  final String? vendorName;

  /// Parsed transaction date, if found.

  final DateTime? transactionDate;

  /// Extracted GSTIN, if found. Typically null on free (ML Kit) tier.

  final String? gstin;

  const ScanReceiptModel({
    required this.rawText,
    required this.confidence,
    required this.amount,
    required this.vendorName,
    required this.transactionDate,
    required this.gstin,
  });
  @override
  List<Object?> get props => [
    rawText,
    confidence,
    amount,
    vendorName,
    transactionDate,
    gstin,
  ];

  /// Converts this model to a domain [ScannedReceiptEntity].
  ScannedReceiptEntity toEntity() {
    return ScannedReceiptEntity(
      rawText: rawText,
      confidence: confidence,
      amount: amount,
      vendorName: vendorName,
      transactionDate: transactionDate,
      gstin: gstin,
    );
  }
}
