import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A single metric block used inside [DashboardSpendSummaryCard] to display
/// a labeled value (e.g. daily average or budget left).
class DashboardMetricBlock extends StatelessWidget {
  /// Creates a [DashboardMetricBlock].
  const DashboardMetricBlock({
    super.key,
    required this.label,
    required this.value,
    this.accent = false,
  });

  /// The label shown above the value.
  final String label;

  /// The numeric or formatted value to display.
  final String value;

  /// Whether the value text should use an accent (primary) color.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: accent ? AppColors.primary : AppColors.darkTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
