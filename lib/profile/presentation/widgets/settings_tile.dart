import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/profile/presentation/widgets/icon_badge.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A tappable settings row with an icon badge, title, subtitle, and chevron trailing.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    this.trailingWidget,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.borderRadius,
    this.contentPadding,
  });

  /// The icon displayed in the leading badge.
  final IconData icon;
  final Widget? trailingWidget;

  /// The primary text label.
  final String title;

  /// The secondary text description.
  final String subtitle;

  /// Callback invoked when the tile is tapped.
  final VoidCallback? onTap;

  /// Optional color override for the icon badge.
  final Color? iconColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return Material(
      animationDuration: const Duration(milliseconds: 200),
      animateColor: true,

      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: ListTile(
        contentPadding: contentPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 0),
        ),
        onTap: onTap,
        minVerticalPadding: 14,
        leading: IconBadge(icon: icon, color: iconColor ?? Colors.white),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13.6, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.darkTextMuted,
            fontSize: 11.5,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing:
            trailingWidget ??
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.darkTextSecondary,
              weight: 0.1,
              grade: 1,
              size: 16.5,
            ),
      ),
    );
  }
}
