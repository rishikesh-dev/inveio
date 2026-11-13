import 'package:equatable/equatable.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/extraction_result.dart';

/// Structured receipt data produced by the scan text parser.
///
/// Each field keeps its own [ExtractionResult] so the UI can highlight the
/// values the parser was unsure about. This is a draft — it is never persisted
/// directly; the add-expense/add-invoice forms map it after user review.
class ParsedReceipt extends Equatable {
  /// Creates a [ParsedReceipt].
  const ParsedReceipt({
    required this.rawText,
    required this.amount,
    required this.date,
    required this.vendor,
    required this.gstin,
  });

  /// Parsed total amount, if found.
  final ExtractionResult<double> amount;

  /// Parsed transaction date, normalized to a calendar date, if valid.
  final ExtractionResult<DateTime> date;

  /// Parsed vendor/business name, if found.
  final ExtractionResult<String> vendor;

  /// Parsed counterparty GSTIN, if found.
  final ExtractionResult<String> gstin;

  /// Full raw OCR text, kept for debugging and fixtures.
  final String rawText;

  /// Whether any field is missing or was extracted with low confidence.
  bool get needsReview =>
      amount.value == null ||
      !amount.isHighConfidence ||
      date.value == null ||
      !date.isHighConfidence ||
      vendor.value == null ||
      !vendor.isHighConfidence ||
      gstin.value == null ||
      !gstin.isHighConfidence;

  /// Returns a copy with the given fields replaced.
  ParsedReceipt copyWith({
    ExtractionResult<double>? amount,
    ExtractionResult<DateTime>? date,
    ExtractionResult<String>? vendor,
    ExtractionResult<String>? gstin,
    String? rawText,
  }) {
    return ParsedReceipt(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      vendor: vendor ?? this.vendor,
      gstin: gstin ?? this.gstin,
      rawText: rawText ?? this.rawText,
    );
  }

  @override
  List<Object?> get props => [
    rawText,
    amount.value,
    amount.isHighConfidence,
    date.value,
    date.isHighConfidence,
    vendor.value,
    vendor.isHighConfidence,
    gstin.value,
    gstin.isHighConfidence,
  ];
}
