import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/scan_text_parser.dart';

/// A single OCR line: its [text] and the row it sits on in the image.
class _Line {
  const _Line(this.text, this.top, [this.height = 12]);

  final String text;
  final double top;
  final double height;
}

TextLine _toLine(_Line line) {
  return TextLine(
    text: line.text,
    elements: const [],
    boundingBox: Rect.fromLTWH(0, line.top, 200, line.height),
    recognizedLanguages: const [],
    cornerPoints: const [],
    confidence: null,
    angle: null,
  );
}

/// Builds the [RecognizedText] a fixture receipt would produce.
RecognizedText _receipt(List<_Line> lines) {
  final textLines = [for (final line in lines) _toLine(line)];
  final text = textLines.map((line) => line.text).join('\n');
  return RecognizedText(
    text: text,
    blocks: [
      TextBlock(
        text: text,
        lines: textLines,
        boundingBox: const Rect.fromLTWH(0, 0, 200, 400),
        recognizedLanguages: const [],
        cornerPoints: const [],
      ),
    ],
  );
}

void main() {
  group('ScanTextParser.parse', () {
    test('sample receipt reads the printed amount, not the phone number', () {
      final receipt = _receipt(const [
        _Line('Tel: 123-456-7890', 0),
        _Line('AMOUNT 84.80', 20),
        _Line('Sub-total 76.80', 40),
        _Line('Sales Tax 8.00', 60),
        _Line('Balance 84.80', 80),
      ]);

      final parsed = ScanTextParser.parse(receipt);

      expect(parsed.amount.value, 84.80);
      expect(parsed.amount.isHighConfidence, isTrue);
    });

    test('falls back to the tallest decimal number without a total label', () {
      final receipt = _receipt(const [
        _Line('Tel: 123-456-7890', 0),
        _Line('Chicken Rice 120.50', 20, 30),
        _Line('GST 8.00', 60),
      ]);

      final parsed = ScanTextParser.parse(receipt);

      expect(parsed.amount.value, 120.50);
      expect(parsed.amount.isHighConfidence, isFalse);
    });

    test('keeps the full raw OCR text', () {
      final receipt = _receipt(const [_Line('AMOUNT 84.80', 0)]);

      final parsed = ScanTextParser.parse(receipt);

      expect(parsed.rawText, 'AMOUNT 84.80');
    });

    test('needsReview is true when a field is low confidence', () {
      final receipt = _receipt(const [_Line('AMOUNT 84.80', 0)]);

      final parsed = ScanTextParser.parse(receipt);

      expect(parsed.amount.value, 84.80);
      expect(parsed.amount.isHighConfidence, isTrue);
      expect(parsed.needsReview, isTrue);
    });

    test('parses the receipt date into a DateTime', () {
      final receipt = _receipt(const [_Line('Invoice date: 12/03/2026', 0)]);

      final parsed = ScanTextParser.parse(receipt);

      expect(parsed.date.value, DateTime(2026, 3, 12));
    });
  });

  group('ScanTextParser.extractTransactionDate', () {
    const formats = {
      'dd/MM/yyyy': '12/03/2026',
      'dd-MM-yyyy': '12-03-2026',
      'dd.MM.yyyy': '12.03.2026',
      'dd/MM/yy': '12/03/26',
      '12 Mar 2026': '12 Mar 2026',
      '12 March 2026': '12 March 2026',
      'mixed case month name': '12 march 2026',
      'single-digit day': '5/7/2026',
    };

    for (final entry in formats.entries) {
      test('parses ${entry.key}', () {
        final result = ScanTextParser.extractTransactionDate(
          'Some receipt text\nDate: ${entry.value}\nTotal: 100',
        );

        final expected = entry.key == 'single-digit day'
            ? DateTime(2026, 7, 5)
            : DateTime(2026, 3, 12);
        expect(result.value, expected);
      });
    }

    test('maps a two-digit year into the 2000s', () {
      final result = ScanTextParser.extractTransactionDate('05/07/24');

      expect(result.value, DateTime(2024, 7, 5));
    });

    test('rejects an impossible calendar date', () {
      final result = ScanTextParser.extractTransactionDate('31/02/2025');

      expect(result.value, isNull);
    });

    test('rejects a date more than one day in the future', () {
      final result = ScanTextParser.extractTransactionDate('01/01/2099');

      expect(result.value, isNull);
    });

    test('accepts tomorrow', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final day = tomorrow.day.toString().padLeft(2, '0');
      final month = tomorrow.month.toString().padLeft(2, '0');

      final result = ScanTextParser.extractTransactionDate(
        '$day/$month/${tomorrow.year}',
      );

      expect(
        result.value,
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      );
    });

    test('keeps looking past an invalid candidate', () {
      final result = ScanTextParser.extractTransactionDate(
        'Due 31/02/2025\nPaid 12/03/2026',
      );

      expect(result.value, DateTime(2026, 3, 12));
    });

    test('returns null when no date is present', () {
      final result = ScanTextParser.extractTransactionDate(
        'AMOUNT 84.80\nSub-total 76.80\nSales Tax 8.00',
      );

      expect(result.value, isNull);
    });
  });
}
