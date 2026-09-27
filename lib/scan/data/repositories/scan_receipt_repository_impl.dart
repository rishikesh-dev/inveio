import 'dart:io';

import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/receipt_text_recognition_data_source.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/receipt_scanner_data_source.dart';
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:inveio/scan/domain/repositories/scan_receipt_repository.dart';

import 'package:fpdart/fpdart.dart';

class ScanReceiptRepositoryImpl extends ScanReceiptRepository {
  final ReceiptTextRecognitionDataSource _textRecognitionDataSource;
  final ReceiptScannerDataSource _receiptScannerDataSource;

  ScanReceiptRepositoryImpl({
    required ReceiptTextRecognitionDataSource textRecognitionDataSource,
    required ReceiptScannerDataSource receiptScannerDataSource,
  }) : _textRecognitionDataSource = textRecognitionDataSource,
       _receiptScannerDataSource = receiptScannerDataSource;

  @override
  Future<Either<Failure, ScannedReceiptEntity>> extractReceiptData(
    File image,
  ) async {
    try {
      final model = await _textRecognitionDataSource.extractReceipt(image);
      return right(model.toEntity());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, File>> scanReceipt() async {
    try {
      return right(await _receiptScannerDataSource.scanDocument());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }
}
