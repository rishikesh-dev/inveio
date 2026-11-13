import 'dart:io';

import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/receipt_text_recognition_data_source.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/receipt_scanner_data_source.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/scan_exceptions.dart';
import 'package:inveio/scan/domain/failures/scan_failures.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
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
  Future<Either<Failure, ParsedReceipt>> extractReceiptData(File image) async {
    try {
      final receipt = await _textRecognitionDataSource.extractReceipt(image);
      return right(receipt);
    } catch (_) {
      return const Left(
        CacheFailure('Could not read the document. Please try again.'),
      );
    }
  }

  @override
  Future<Either<Failure, File>> scanReceipt() async {
    try {
      return right(await _receiptScannerDataSource.scanDocument());
    } on ScanCancelledException {
      return const Left(ScanCancelledFailure());
    } catch (_) {
      return const Left(
        CacheFailure('Could not scan the document. Please try again.'),
      );
    }
  }
}
