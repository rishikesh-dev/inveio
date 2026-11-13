import 'package:flutter/material.dart';
import 'package:inveio/shared/utils/password_validator.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Requirement checklist shown below password fields so the user sees which
/// [PasswordValidator] conditions are met while typing.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.controller});

  /// Controller of the password field being checked.
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final checks = PasswordValidator.checks(value.text);
        if (checks.isEmpty) return const SizedBox.shrink();

        return Column(
          children: checks.map((item) {
            final isMet = item.$2;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    isMet ? LucideIcons.checkCircle : LucideIcons.circle,
                    size: 14,
                    color: isMet ? AppColors.primary : AppColors.darkTextMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.$1,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isMet
                          ? AppColors.primary
                          : AppColors.darkTextSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
