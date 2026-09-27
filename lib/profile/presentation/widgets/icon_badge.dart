import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A rounded container that displays an icon, typically used as a leading badge in tiles.
class IconBadge extends StatelessWidget {
  const IconBadge({super.key, required this.icon, this.color});

  /// The icon to display inside the badge.
  final IconData icon;

  /// Optional color for the icon; defaults to [AppColors.primaryLight].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withAlpha(13),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color ?? AppColors.primaryLight, size: 21),
    );
  }
}
