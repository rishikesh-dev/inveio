import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A widget that displays an "OR" divider between authentication options.
class OrDivider extends StatelessWidget {
  /// Creates an [OrDivider].
  const OrDivider({super.key});

  /// Builds the divider with "OR" text centered between two horizontal lines.
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.darkBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.darkTextSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.darkBorder)),
      ],
    );
  }
}
