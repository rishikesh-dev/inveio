import 'dart:io';

import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class ScanReceiptRepository {
  Future<Either<Failure, ScannedReceiptEntity>> extractReceiptData(File image);
  Future<Either<Failure, File>> scanReceipt();
}
