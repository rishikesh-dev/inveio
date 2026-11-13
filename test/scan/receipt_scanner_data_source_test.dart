import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/receipt_scanner_data_source_impl.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/scan_exceptions.dart';
import 'package:mocktail/mocktail.dart';

class MockDocumentScanner extends Mock implements DocumentScanner {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDocumentScanner scanner;

  setUp(() {
    scanner = MockDocumentScanner();
  });

  ReceiptScannerDataSourceImpl buildDataSource() {
    return ReceiptScannerDataSourceImpl(scannedDocuments: scanner);
  }

  group('ReceiptScannerDataSourceImpl.scanDocument', () {
    test('returns the first scanned page as a file', () async {
      when(() => scanner.scanDocument()).thenAnswer(
        (_) async => DocumentScanningResult.fromJson(<String, dynamic>{
          'images': <String>['/tmp/receipt.png'],
          'pdf': null,
        }),
      );

      final file = await buildDataSource().scanDocument();

      expect(file.path, '/tmp/receipt.png');
    });

    test('treats a scanner cancel as ScanCancelledException', () async {
      when(() => scanner.scanDocument()).thenThrow(
        PlatformException(
          code: 'DocumentScanner',
          message: 'Operation cancelled',
        ),
      );

      await expectLater(
        buildDataSource().scanDocument(),
        throwsA(isA<ScanCancelledException>()),
      );
    });

    test('treats an empty scan result as a cancellation', () async {
      when(() => scanner.scanDocument()).thenAnswer(
        (_) async => DocumentScanningResult.fromJson(<String, dynamic>{
          'images': null,
          'pdf': null,
        }),
      );

      await expectLater(
        buildDataSource().scanDocument(),
        throwsA(isA<ScanCancelledException>()),
      );
    });

    test('rethrows other platform errors as generic failures', () async {
      when(() => scanner.scanDocument()).thenThrow(
        PlatformException(code: 'DocumentScanner', message: 'Unknown Error'),
      );

      await expectLater(
        buildDataSource().scanDocument(),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('Failed to scan document'),
          ),
        ),
      );
    });

    test('converts file: URIs to plain paths', () async {
      when(() => scanner.scanDocument()).thenAnswer(
        (_) async => DocumentScanningResult.fromJson(<String, dynamic>{
          'images': <String>['file:///tmp/receipt.png'],
          'pdf': null,
        }),
      );

      final file = await buildDataSource().scanDocument();

      expect(file.path, '/tmp/receipt.png');
    });
  });
}
