import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/profile/presentation/widgets/icon_badge.dart';
import 'package:flutter/material.dart';

/// A settings row with an icon badge, title, subtitle, and a [Switch] control.
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  /// The icon displayed in the leading badge.
  final IconData icon;

  /// The primary text label.
  final String title;

  /// The secondary text description.
  final String subtitle;

  /// The current boolean value of the switch.
  final bool value;

  /// Callback invoked when the switch value changes.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 14,
      leading: IconBadge(icon: icon),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.darkTextMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
