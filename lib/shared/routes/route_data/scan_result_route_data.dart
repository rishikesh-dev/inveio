import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';

/// Payload shared between a completed scan and the add-expense/add-invoice
/// screens that consume the extracted data.
class ScanResultRouteData {
  const ScanResultRouteData({required this.data, this.imagePath});

  /// Extracted receipt/invoice data.
  final ScannedReceiptEntity data;

  /// Local path of the scanned document image, when available.
  final String? imagePath;
}