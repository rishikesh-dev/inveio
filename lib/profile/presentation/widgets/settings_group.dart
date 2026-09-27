import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A container that groups [SettingsTile] widgets with rounded corners and dividers.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  /// The list of widgets to display within the group.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkCardAlt,
        border: Border.all(color: AppColors.darkBorderSoft),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(color: AppColors.darkBorderSoft),
          ],
        ],
      ),
    );
  }
}
