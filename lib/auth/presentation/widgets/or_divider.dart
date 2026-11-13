import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A widget that displays an "or continue with" divider between authentication options.
class OrDivider extends StatelessWidget {
  /// Creates an [OrDivider].
  const OrDivider({super.key});

  /// Builds the divider with "or continue with" text centered between two horizontal lines.
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.darkBorder, thickness: 0.5)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(
              color: AppColors.darkTextMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.darkBorder, thickness: 0.5)),
      ],
    );
  }
}
