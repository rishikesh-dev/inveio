import 'dart:io';

import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:fpdart/fpdart.dart';

abstract class ScanReceiptRepository {
  Future<Either<Failure, ParsedReceipt>> extractReceiptData(File image);
  Future<Either<Failure, File>> scanReceipt();
}
