import 'package:flutter/material.dart';

/// A styled elevated button with an optional icon and custom border radius.
class NeonButton extends StatelessWidget {
  /// Creates a [NeonButton] with the given [label] and [onPressed] callback.
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.icon,
    this.height,
    this.borderRadius,
    this.margin,
    this.padding,
    this.iconAlignment,
    this.labelStyle,
  });

  /// The button's text label.
  final String label;
  final TextStyle? labelStyle;

  /// Background color override.
  final Color? color;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// Callback invoked when the button is pressed.
  final VoidCallback? onPressed;

  /// Height override for the button.
  final double? height;

  /// Custom border radius for the button.
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final IconAlignment? iconAlignment;

  @override
  /// Builds the elevated button with an optional icon and custom shape.
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: margin ?? const EdgeInsets.all(0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon != null ? Icon(icon) : null,
          iconAlignment: iconAlignment,
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
            backgroundColor: WidgetStatePropertyAll(color),
            padding: WidgetStatePropertyAll(padding ?? const EdgeInsets.all(0)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(12),
              ),
            ),
          ),
          label: Text(
            label,
            style:
                labelStyle ??
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
      ),
    );
  }
}
