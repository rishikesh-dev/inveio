import 'dart:io';

import 'package:inveio/scan/data/datasources/local/receipt_scanner/receipt_scanner_data_source.dart';
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
        throw Exception('No scanned document found');
      }

      final imagePath = images.first;

      final filePath = imagePath.startsWith('file:')
          ? Uri.parse(imagePath).toFilePath()
          : imagePath;

      return File(filePath);
    } on PlatformException {
      throw Exception('Failed to scan document');
    }
  }
}
