import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:flutter/material.dart';

/// The full-screen camera-based receipt scanner with an extracted details
/// bottom sheet overlay.
class ScanReceiptScreen extends StatelessWidget {
  const ScanReceiptScreen({super.key, this.scannedData});

  /// The scanned receipt data. When null, a default mock is used
  /// (temporary until ML/Gemini integration is wired).
  final ScannedReceiptEntity? scannedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor);
  }
}
