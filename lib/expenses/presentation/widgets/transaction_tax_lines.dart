import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A row displaying a tax component label, percentage, and amount.
class TaxLine extends StatelessWidget {
  const TaxLine({
    super.key,
    required this.label,
    required this.percent,
    required this.amount,
  });

  /// The tax component name (e.g. CGST).
  final String label;

  /// The tax percentage string (e.g. "9%").
  final String percent;

  /// The formatted tax amount.
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                percent,
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// A row displaying a total label and its amount in the accent color.
class TotalLine extends StatelessWidget {
  const TotalLine({super.key, required this.label, required this.amount});

  /// The total line label.
  final String label;

  /// The formatted total amount.
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
