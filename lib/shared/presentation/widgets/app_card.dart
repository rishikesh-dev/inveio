import 'package:flutter/material.dart';

/// An animated container card with customizable padding, margin, radius, and border color.
class AppCard extends StatelessWidget {
  /// Creates an [AppCard] wrapping the given [child].
  const AppCard({
    super.key,
    this.padding,
    this.margin,
    this.radius,
    this.color,
    this.borderColor,
    required this.child,
  });

  /// Inner padding of the card.
  final EdgeInsets? padding;

  /// Outer margin of the card.
  final EdgeInsets? margin;

  /// Border radius of the card (default: 20).
  final double? radius;

  /// Background color of the card.
  final Color? color;

  /// Border color of the card.
  final Color? borderColor;

  /// The widget wrapped by this card.
  final Widget child;

  @override
  /// Builds the animated card container with custom decoration.
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        border: Border.all(color: borderColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(radius ?? 20),
      ),
      child: child,
    );
  }
}
