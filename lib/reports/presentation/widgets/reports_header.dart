import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportsHeader extends StatelessWidget {
  const ReportsHeader({
    super.key,
    required this.period,
    required this.onPeriodTap,
  });

  final String period;
  final VoidCallback onPeriodTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Reports',
            style: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        AccentChip(
          label: period,
          icon: LucideIcons.calendar,
          compact: true,
          onTap: onPeriodTap,
        ),
      ],
    );
  }
}
