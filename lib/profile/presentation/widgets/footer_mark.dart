import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A branded footer label displayed at the bottom of the profile screen.
class FooterMark extends StatelessWidget {
  const FooterMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'INVEIO ENTERPRISE V4.2.1',
          style: TextStyle(
            color: AppColors.darkTextMuted,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'MADE WITH PRECISION IN BANGALORE',
          style: TextStyle(
            color: AppColors.darkTextMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
