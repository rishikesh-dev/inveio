import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/expenses/presentation/widgets/gst_split_bar.dart';
import 'package:flutter/material.dart';

/// Displays the GST breakdown (CGST/SGST/IGST) for invoices.
class InvoiceGstDisplay extends StatelessWidget {
  const InvoiceGstDisplay({
    super.key,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.taxableAmount,
    required this.isInterState,
  });

  /// The computed CGST amount.
  final double cgst;

  /// The computed SGST amount.
  final double sgst;

  /// The computed IGST amount.
  final double igst;

  /// The taxable amount before GST.
  final double taxableAmount;

  /// Whether the transaction is inter-state.
  final bool isInterState;

  @override
  Widget build(BuildContext context) {
    final totalTax = cgst + sgst + igst;
    final rate = totalTax > 0 && taxableAmount > 0
        ? '${(totalTax / taxableAmount * 100).toStringAsFixed(1)}%'
        : '\u2014';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GstSplitBar(
          isInterState: isInterState,
          cgst: cgst,
          sgst: sgst,
          igst: igst,
        ),
        const SizedBox(height: 8),
        Text(
          'GST Rate: $rate',
          style: const TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
        ),
      ],
    );
  }
}
