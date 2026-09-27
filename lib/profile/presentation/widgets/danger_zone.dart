import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DangerZone extends StatelessWidget {
  const DangerZone({super.key, required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: theme.dividerColor.withValues(alpha: .3)),

        const SizedBox(height: 20),

        Text(
          'Danger Zone',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppColors.expense,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.expense,
              side: const BorderSide(color: AppColors.expense),
            ),
          ),
        ),
      ],
    );
  }
}
