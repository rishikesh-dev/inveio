import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/profile/presentation/widgets/icon_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A settings row with a slider to adjust the AI confidence threshold.
class ConfidenceTile extends StatelessWidget {
  const ConfidenceTile({super.key, required this.value, required this.onChanged});

  /// The current confidence threshold value (0.5 to 1.0).
  final double value;

  /// Callback invoked when the slider value changes.
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: [
          const IconBadge(icon: LucideIcons.badgePercent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Confidence Threshold',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'AI strictness for auto-categorization',
                  style: TextStyle(
                    color: AppColors.darkTextMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  value: value,
                  min: 0.5,
                  max: 1,
                  divisions: 10,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
