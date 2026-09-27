import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// A row of dots displayed at the bottom of the splash screen.
class BottomDots extends StatelessWidget {
  /// The opacity used to fade the dots in and out.
  final double opacity;

  const BottomDots({super.key, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 52,
      left: 0,
      right: 0,
      child: Opacity(
        opacity: opacity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(8, SplashColors.green),
            const SizedBox(width: 8),
            _dot(6, SplashColors.lightGreen),
            const SizedBox(width: 6),
            _dot(6, SplashColors.lightGreen),
          ],
        ),
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
