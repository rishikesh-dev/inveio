import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// A pill-shaped badge displaying a GST rate.
class GstPill extends StatelessWidget {
  /// The GST rate text displayed inside the pill.
  final String label;

  /// Whether this pill is rendered with the active (filled) style.
  final bool active;

  /// Whether this pill uses the accent (lime) colour scheme.
  final bool accent;

  const GstPill(
    this.label, {
    super.key,
    this.active = false,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? SplashColors.green
        : accent
        ? SplashColors.lime
        : Colors.white;
    final fg = active
        ? Colors.white
        : accent
        ? SplashColors.deepGreen
        : SplashColors.midGreen;
    final border = active
        ? SplashColors.green
        : accent
        ? SplashColors.lime
        : SplashColors.lightGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
