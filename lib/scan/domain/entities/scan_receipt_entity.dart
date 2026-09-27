import 'package:equatable/equatable.dart';

/// Structured data extracted from a scanned receipt, before user confirmation.
///
/// This is a draft — never persisted directly. UI maps this into a
/// [TransactionModel] only after the user reviews/edits and confirms.
class ScannedReceiptEntity extends Equatable {
  /// Creates a [ScannedReceiptEntity].
  const ScannedReceiptEntity({
    required this.rawText,
    required this.confidence,
    this.amount,
    this.vendorName,
    this.transactionDate,
    this.gstin,
  });

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

  @override
  List<Object?> get props => [
    rawText,
    confidence,
    amount,
    vendorName,
    transactionDate,
    gstin,
  ];
}

class ScanConfidence extends Equatable {
  const ScanConfidence({
    required this.amount,
    required this.transactionDate,
    required this.vendorName,
    required this.gstin,
  });

  final bool amount;
  final bool transactionDate;
  final bool vendorName;
  final bool gstin;

  @override
  List<Object?> get props => [amount, transactionDate, vendorName, gstin];
}
