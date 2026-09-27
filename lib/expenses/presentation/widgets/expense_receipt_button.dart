import 'dart:io';

import 'package:inveio/shared/presentation/widgets/error_banner.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Section to attach (and preview) a receipt image for the expense.
class ExpenseReceiptButton extends StatelessWidget {
  const ExpenseReceiptButton({
    super.key,
    required this.receiptPath,
    required this.onPressed,
    required this.onRemove,
  });

  /// Local path of the attached receipt image, if any.
  final String? receiptPath;

  /// Callback when the user wants to attach/pick a receipt.
  final VoidCallback onPressed;

  /// Callback when the user removes the attached receipt.
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final path = receiptPath;
    if (path != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                alignment: Alignment.center,
                color: AppColors.darkCard,
                child: const Icon(
                  LucideIcons.imageOff,
                  color: AppColors.darkTextMuted,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                LucideIcons.paperclip,
                color: AppColors.darkTextMuted,
                size: 18,
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onPressed,
                icon: const Icon(
                  LucideIcons.refreshCw,
                  color: AppColors.darkTextMuted,
                  size: 18,
                ),
                label: const Text(
                  'Replace receipt',
                  style: TextStyle(
                    color: AppColors.darkTextMuted,
                    fontSize: 13,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(
                  LucideIcons.trash2,
                  color: AppColors.danger,
                  size: 18,
                ),
                label: const Text(
                  'Remove',
                  style: TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        const Icon(
          LucideIcons.paperclip,
          color: AppColors.darkTextMuted,
          size: 18,
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(
            LucideIcons.image,
            color: AppColors.darkTextMuted,
            size: 18,
          ),
          label: const Text(
            'Attach receipt',
            style: TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

/// Warning banner for cash payments above the ITC threshold.
class ExpenseCashWarning extends StatelessWidget {
  const ExpenseCashWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return const ErrorBanner(
      message: 'Cash payments above \u20B910,000 may affect ITC eligibility',
    );
  }
}