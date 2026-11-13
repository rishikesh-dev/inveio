import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A quick action button displayed as an icon circle with a label below.
class QuickActionWidget extends StatelessWidget {
  /// Creates a [QuickActionWidget] with the given [icon] and [title].
  const QuickActionWidget({
    super.key,
    required this.icon,
    required this.title,
    this.bgColor,
    this.iconColor,
    this.onTap,
  });

  /// The icon displayed inside the circle.
  final IconData icon;

  /// The label displayed below the icon.
  final String title;

  /// Background color of the icon circle.
  final Color? bgColor;

  /// Color of the icon.
  final Color? iconColor;

  /// Callback when the action is tapped.
  final Function()? onTap;
  @override
  /// Builds the quick action icon circle with a label below.
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        InkResponse(
          onTap: onTap,
          enableFeedback: true,
          radius: 20,
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(100),
          child: CircleAvatar(
            backgroundColor: bgColor ?? AppColors.primaryDark,
            radius: 27,
            child: Icon(icon, color: iconColor ?? AppColors.primary),
          ),
        ),
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
