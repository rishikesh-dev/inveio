import 'dart:io';

import 'package:inveio/scan/data/datasources/local/ml_kit/receipt_text_recognition_data_source.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/scan_text_parser.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// ML Kit implementation of [ReceiptTextRecognitionDataSource].
class ReceiptTextRecognitionDataSourceImpl
    implements ReceiptTextRecognitionDataSource {
  final TextRecognizer textRecognizer;

  ReceiptTextRecognitionDataSourceImpl({required this.textRecognizer});

  @override
  Future<ParsedReceipt> extractReceipt(File image) async {
    final extractedData = await textRecognizer.processImage(
      InputImage.fromFile(image),
    );
    return ScanTextParser.parse(extractedData);
  }
}
