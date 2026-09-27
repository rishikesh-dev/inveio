import 'dart:io';

abstract class ReceiptScannerDataSource {
  Future<File> scanDocument();
}
