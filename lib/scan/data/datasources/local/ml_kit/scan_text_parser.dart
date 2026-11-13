import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/extraction_result.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';

class ScanTextParser {
  /// Parses all structured fields out of a recognized receipt.
  ///
  /// Aggregates the individual extraction helpers; their logic is unchanged.
  static ParsedReceipt parse(RecognizedText text) {
    return ParsedReceipt(
      rawText: text.text,
      amount: extractAmount(text),
      date: extractTransactionDate(text.text),
      vendor: extractVendorName(text.blocks),
      gstin: extractGstIn(text.text),
    );
  }

  // ---------- Amount ----------

  // Commas are removed before matching, so 1,23,456.00 works.
  static final _amountPattern = RegExp(r'\d+(?:\.\d{1,2})?');

  // Contact / tax identifier lines, never an amount.
  static final _skipPattern = RegExp(
    r'\b(?:tel|phone|ph|mob|mobile|gstin|invoice no|bill no|order no)\b',
    caseSensitive: false,
  );

  static const _strongTotals = [
    'grand total',
    'total amount',
    'amount payable',
    'net payable',
    'net amount',
    'amount due',
    'balance due',
    'total payable',
    'bill total',
    'net total',
  ];

  static const _totalNoise = [
    'qty',
    'quantity',
    'item',
    'tax',
    'gst',
    'discount',
  ];

  static ExtractionResult<double> extractAmount(RecognizedText text) {
    final lines = [for (final b in text.blocks) ...b.lines];

    // Fallback: the number with the largest bounding-box height (biggest
    // font), which is usually the printed total. On a tie the larger value
    // wins. Only numbers with a decimal part qualify, so phone numbers and
    // long ids are ignored even before the label check.
    double? fallback;
    double? fallbackHeight;
    for (final line in lines) {
      if (_skipPattern.hasMatch(line.text)) continue;

      final normalized = line.text.replaceAll(',', '');
      for (final match in _amountPattern.allMatches(normalized)) {
        final raw = match.group(0)!;
        final hasDecimalPart = raw.contains('.');
        final isLongWholeNumber = !hasDecimalPart && raw.length >= 6;
        if (!hasDecimalPart || isLongWholeNumber) continue;

        final value = double.tryParse(raw);
        if (value == null) continue;

        final height = line.boundingBox.height;
        if (fallbackHeight == null ||
            height > fallbackHeight ||
            (height == fallbackHeight && value > fallback!)) {
          fallback = value;
          fallbackHeight = height;
        }
      }
    }

    double? best;
    var bestRank = 99;
    for (final line in lines) {
      final rank = _totalRank(line.text.toLowerCase());
      if (rank == null) continue;

      final value = _lastAmount(line.text) ?? _amountToRight(line, lines);
      if (value == null) continue;

      // Lower rank wins. On a tie the later line wins (totals sit at the bottom).
      if (rank <= bestRank) {
        best = value;
        bestRank = rank;
      }
    }

    if (best != null) return ExtractionResult(best, true);
    return ExtractionResult(fallback, false);
  }

  // 0 = strong total label, 1 = plain total/amount/balance, null = not a total.
  static int? _totalRank(String lower) {
    if (_skipPattern.hasMatch(lower)) return null;
    if (lower.contains('sub')) return null;
    if (_strongTotals.any(lower.contains)) return 0;
    if (!_totalNoise.any(lower.contains) &&
        (lower.contains('total') ||
            lower.contains('amount') ||
            lower.contains('balance'))) {
      return 1;
    }
    return null;
  }

  // Last number on the line, so "Total Qty 3   531.00" gives 531.00.
  static double? _lastAmount(String text) {
    final matches = _amountPattern.allMatches(text.replaceAll(',', ''));
    if (matches.isEmpty) return null;
    return double.tryParse(matches.last.group(0)!);
  }

  // Label and number are in separate lines: take the nearest number
  // to the right that sits on the same row.
  static double? _amountToRight(TextLine label, List<TextLine> lines) {
    final box = label.boundingBox;
    final tolerance = box.height * 0.5; // handles slightly tilted photos

    TextLine? nearest;
    var minGap = double.infinity;

    for (final l in lines) {
      if (identical(l, label)) continue;
      final b = l.boundingBox;

      final cy = b.center.dy;
      if (cy < box.top - tolerance || cy > box.bottom + tolerance) continue;

      final gap = b.left - box.right;
      if (gap < 0 || gap >= minGap) continue;
      if (_lastAmount(l.text) == null) continue;

      nearest = l;
      minGap = gap;
    }
    return nearest == null ? null : _lastAmount(nearest.text);
  }

  // ---------- Date ----------

  // Day-first numeric dates, with `/`, `-` or `.` separators. The year may be
  // two or four digits.
  static final _numericDatePattern = RegExp(
    r'\b(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})\b',
  );

  // "12 Mar 2026", "12 March 2026", case-insensitive. Abbreviations and full
  // month names are both accepted.
  static final _monthNameDatePattern = RegExp(
    r'\b(\d{1,2})\s+(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:t(?:ember)?)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?)\s+(\d{4})\b',
    caseSensitive: false,
  );

  static const _monthNumbers = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  /// Parses the first valid day-first date found in [rawText].
  ///
  /// Impossible calendar dates and dates more than one day in the future are
  /// ignored rather than normalized or defaulted.
  static ExtractionResult<DateTime> extractTransactionDate(String rawText) {
    for (final match in _numericDatePattern.allMatches(rawText)) {
      final date = _parseNumericDate(match);
      if (date != null) return ExtractionResult(date, false);
    }

    for (final match in _monthNameDatePattern.allMatches(rawText)) {
      final date = _parseNamedDate(match);
      if (date != null) return ExtractionResult(date, false);
    }

    return const ExtractionResult(null, false);
  }

  static DateTime? _parseNumericDate(RegExpMatch match) {
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final yearText = match.group(3)!;
    final year = yearText.length == 2
        ? 2000 + int.parse(yearText)
        : int.parse(yearText);
    return _validatedDate(year, month, day);
  }

  static DateTime? _parseNamedDate(RegExpMatch match) {
    final day = int.parse(match.group(1)!);
    final month = _monthNumbers[match.group(2)!.toLowerCase().substring(0, 3)];
    final year = int.parse(match.group(3)!);
    if (month == null) return null;
    return _validatedDate(year, month, day);
  }

  static DateTime? _validatedDate(int year, int month, int day) {
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }

    final now = DateTime.now();
    final latestAllowed = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    if (date.isAfter(latestAllowed)) return null;

    return date;
  }

  // ---------- Vendor (unchanged) ----------

  static ExtractionResult<String> extractVendorName(List<TextBlock> blocks) {
    final anchors = ['billed to', 'bill to', 'from'];

    for (final block in blocks) {
      final lines = block.lines;
      for (int i = 0; i < lines.length; i++) {
        final lower = lines[i].text.trim().toLowerCase();
        if (anchors.any((a) => lower.contains(a))) {
          // same block, next line
          if (i + 1 < lines.length) {
            return ExtractionResult(lines[i + 1].text.trim(), true);
          }
          // anchor was last line in block — check next block by vertical position
          final anchorBottom = block.boundingBox.bottom;
          TextBlock? closest;
          double minDist = double.infinity;
          for (final b in blocks) {
            if (b == block) continue;
            final dist = b.boundingBox.top - anchorBottom;
            if (dist > 0 && dist < minDist) {
              minDist = dist;
              closest = b;
            }
          }
          if (closest != null) {
            return ExtractionResult(
              closest.text.split('\n').first.trim(),
              true,
            );
          }
        }
      }
    }
    return const ExtractionResult(null, false);
  }

  // ---------- GSTIN (unchanged) ----------

  static ExtractionResult<String> extractGstIn(String rawText) {
    // Strict, near-unique shape — high confidence when matched.
    final gstInPattern = RegExp(
      r'([0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z])',
    );

    final match = gstInPattern.firstMatch(rawText);
    if (match == null) {
      return const ExtractionResult(null, false);
    }
    return ExtractionResult(match.group(1), true);
  }
}
