import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Animated horizontal bar showing the CGST/SGST/IGST split.
class GstSplitBar extends StatelessWidget {
  const GstSplitBar({
    super.key,
    required this.isInterState,
    required this.cgst,
    required this.sgst,
    required this.igst,
  });

  /// Whether the transaction is inter-state.
  final bool isInterState;

  /// The computed CGST amount.
  final double cgst;

  /// The computed SGST amount.
  final double sgst;

  /// The computed IGST amount.
  final double igst;

  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.elasticOut;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final hasCgst = cgst > 0;
        final hasSgst = sgst > 0;
        final hasIgst = igst > 0;

        double cgstWidth = 0;
        double sgstWidth = 0;
        double igstWidth = 0;

        if (isInterState) {
          igstWidth = maxWidth;
        } else {
          if (hasCgst && hasSgst) {
            cgstWidth = maxWidth / 2;
            sgstWidth = maxWidth / 2;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (hasCgst)
                      AnimatedContainer(
                        duration: _duration,
                        curve: _curve,
                        width: cgstWidth,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    if (hasSgst)
                      AnimatedContainer(
                        duration: _duration,
                        curve: _curve,
                        width: sgstWidth,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                        ),
                      ),
                    if (hasIgst)
                      AnimatedContainer(
                        duration: _duration,
                        curve: _curve,
                        width: igstWidth,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isInterState)
              Text(
                'IGST: ${currency.format(igst)}',
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              )
            else ...[
              Text(
                'CGST: ${currency.format(cgst)}',
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'SGST: ${currency.format(sgst)}',
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
