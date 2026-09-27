import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A placeholder widget shown when the user profile cannot be loaded.
class EmptyProfileState extends StatelessWidget {
  const EmptyProfileState({super.key, required this.onRetry});

  /// Callback invoked when the user taps the retry button.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              LucideIcons.circleAlert,
              color: AppColors.darkTextSecondary,
              size: 32,
            ),
            const SizedBox(height: 12),
            const Text('Profile could not be loaded'),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
