import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// Small sparkling dots that pulse around the splash screen.
class SparkleDots extends StatelessWidget {
  /// The animation value used to drive the sparkle scale and opacity.
  final double animValue;

  const SparkleDots({super.key, required this.animValue});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _sparkle(50, 160, SplashColors.lime, 0.0, animValue),
        _sparkle(130, null, SplashColors.green, 0.7, animValue, right: 70),
        _sparkle(500, 80, SplashColors.gold, 1.4, animValue),
        _sparkle(460, null, SplashColors.lime, 0.3, animValue, right: 100),
      ],
    );
  }

  Widget _sparkle(
    double top,
    double? left,
    Color color,
    double delay,
    double animValue, {
    double? right,
  }) {
    final delayed = (animValue - delay).clamp(0.0, 1.0);
    final scale = 1.0 + 0.8 * (0.5 - (delayed - 0.5).abs()) * 2;
    final opacity = 0.6 + 0.4 * (0.5 - (delayed - 0.5).abs()) * 2;

    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale.clamp(0.5, 2.0),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
