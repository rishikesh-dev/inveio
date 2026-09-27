import 'package:flutter/material.dart';

/// A chip widget with an accent style, supporting selection and compact mode.
class AccentChip extends StatelessWidget {
  /// Creates an [AccentChip] with the given [label].
  const AccentChip({
    super.key,
    required this.label,
    this.selected,
    this.compact,
    this.icon,
    this.onTap,
  });
  /// The text displayed on the chip.
  final String label;
  /// Whether the chip appears in the selected (highlighted) state.
  final bool? selected;
  /// Whether to render the chip in a compact size.
  final bool? compact;
  /// Callback when the chip is tapped.
  final VoidCallback? onTap;
  /// Optional icon shown before the label.
  final IconData? icon;

  @override
  /// Builds the accent chip with selection and compact mode support.
  Widget build(BuildContext context) {
    final isSelected = selected ?? false;
    final isCompact = compact ?? false;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Chip(
        avatar: icon != null
            ? Icon(
                icon,
                size: isCompact ? 14 : 18,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              )
            : null,
        label: Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 12 : 14,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
        visualDensity: isCompact ? VisualDensity.compact : null,
        backgroundColor: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        padding: isCompact
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
            : null,
      ),
    );
  }
}
