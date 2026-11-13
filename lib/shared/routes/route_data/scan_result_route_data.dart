import 'package:inveio/scan/domain/entities/parsed_receipt.dart';

/// Payload shared between a completed scan and the add-expense/add-invoice
/// screens that consume the extracted data.
class ScanResultRouteData {
  const ScanResultRouteData({required this.data, this.imagePath});

  /// Extracted receipt/invoice data.
  final ParsedReceipt data;

  /// Local path of the scanned document image, when available.
  final String? imagePath;
}
