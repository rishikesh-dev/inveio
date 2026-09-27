import 'dart:io';

import 'package:inveio/scan/data/datasources/local/ml_kit/receipt_text_recognition_data_source.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/scan_text_parser.dart';
import 'package:inveio/scan/data/models/scan_receipt_model.dart';
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:intl/intl.dart';

/// ML Kit implementation of [ReceiptTextRecognitionDataSource].
class ReceiptTextRecognitionDataSourceImpl
    implements ReceiptTextRecognitionDataSource {
  final TextRecognizer textRecognizer;

  ReceiptTextRecognitionDataSourceImpl({required this.textRecognizer});

  @override
  Future<ScanReceiptModel> extractReceipt(File image) async {
    final extractedData = await textRecognizer.processImage(
      InputImage.fromFile(image),
    );
    final dateResult = ScanTextParser.extractTransactionDate(
      extractedData.text,
    );
    DateTime? transactionDate;
    if (dateResult.value != null) {
      transactionDate = DateFormat('dd/MM/yyyy').tryParse(dateResult.value!);
    }
    final amountResult = ScanTextParser.extractAmount(extractedData.text);
    final vendorResult = ScanTextParser.extractVendorName(extractedData.blocks);
    final gstinResult = ScanTextParser.extractGstIn(extractedData.text);
    return ScanReceiptModel(
      rawText: extractedData.text,
      confidence: ScanConfidence(
        amount: amountResult.isHighConfidence,
        transactionDate: dateResult.isHighConfidence,
        vendorName: vendorResult.isHighConfidence,
        gstin: gstinResult.isHighConfidence,
      ),
      amount: amountResult.value,
      vendorName: vendorResult.value,
      transactionDate: transactionDate,
      gstin: gstinResult.value,
    );
  }
}
