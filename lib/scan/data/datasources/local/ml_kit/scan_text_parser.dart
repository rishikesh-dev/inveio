import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/extraction_result.dart';

class ScanTextParser {
  static ExtractionResult<double> extractAmount(String rawText) {
    final lines = rawText.split('\n');

    // Matches things like: 531.00, ₹531.00, Rs 531, 1,234.50
    final amountPattern = RegExp(r'(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)');

    double? totalLineAmount;
    double? largestAmount;

    for (final line in lines) {
      final match = amountPattern.firstMatch(line);
      if (match == null) continue;

      final value = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (value == null) continue;

      // Track the largest number seen, as a fallback.
      if (largestAmount == null || value > largestAmount) {
        largestAmount = value;
      }

      // If this line mentions "total" (case-insensitive), prefer it.
      if (line.toLowerCase().contains('total')) {
        totalLineAmount = value;
      }
    }

    if (totalLineAmount != null) {
      return ExtractionResult(totalLineAmount, true); // found via "Total" line
    }
    return ExtractionResult(largestAmount, false); // fallback guess, or null
  }

  static ExtractionResult<String> extractTransactionDate(String rawText) {
    final datePattern = RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})');

    final match = datePattern.firstMatch(rawText);
    if (match == null) {
      return const ExtractionResult(null, false);
    }

    // Loose pattern — could collide with order numbers etc, so never high
    // confidence even when found.
    return ExtractionResult(match.group(1), false);
  }

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
