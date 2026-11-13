import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A row containing a section title and an optional action button.
class SectionTitleRow extends StatelessWidget {
  /// Creates a [SectionTitleRow] with the given [title].
  const SectionTitleRow({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  /// The section title text.
  final String title;

  /// The label for the optional action button.
  final String? action;

  /// Callback when the action button is tapped.
  final VoidCallback? onActionTap;

  @override
  /// Builds the row with a title and an optional action button.
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (action != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              action!,
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}
