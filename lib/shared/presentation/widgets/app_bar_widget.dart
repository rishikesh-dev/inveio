import 'package:flutter/material.dart';

/// A reusable sliver app bar with an optional title, subtitle, leading widget, and actions.
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  /// The primary title text.
  final String? title;

  /// The subtitle displayed below the title.
  final String? subTitle;

  /// Style override for the title text.
  final TextStyle? titleStyle;

  /// Style override for the subtitle text.
  final TextStyle? subTitleStyle;

  /// Optional leading widget displayed before the title.
  final Widget? leading;

  /// Optional action widgets displayed in the app bar.
  final List<Widget>? actions;

  /// The expanded height of the sliver app bar.
  final double? expandedHeight;
  // Option for changing to Sliver or Normal AppBar
  final bool sliver;
  final bool centerTitle;

  /// Creates an [AppBarWidget] with optional title, subtitle, leading, actions, and expanded height.
  const AppBarWidget({
    super.key,
    this.title,
    this.subTitle,
    this.leading,
    this.actions,
    this.titleStyle,
    this.subTitleStyle,
    this.expandedHeight,
    this.sliver = true,
    this.centerTitle = false,
  });

  @override
  /// Builds the sliver app bar with title, subtitle, and actions.
  @override
  Widget build(BuildContext context) {
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title != null
            ? Text(
                title ?? '',
                style:
                    titleStyle ??
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              )
            : const SizedBox(),
        subTitle != null
            ? Text(
                subTitle ?? '',
                style:
                    subTitleStyle ??
                    Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.normal,
                    ),
              )
            : const SizedBox(),
      ],
    );

    if (sliver) {
      return SliverAppBar(
        expandedHeight: expandedHeight,
        centerTitle: centerTitle,
        title: titleColumn,
        leading: leading,
        actions: [...?actions, const SizedBox(width: 16)],
      );
    }

    return AppBar(
      title: titleColumn,
      leading: leading,
      actions: [...?actions, const SizedBox(width: 16)],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
