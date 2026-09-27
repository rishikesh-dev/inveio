import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// Decorative blurred circles placed behind the splash content.
class BackgroundCircles extends StatelessWidget {
  const BackgroundCircles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -80,
          child: _circle(280, SplashColors.paleGreen),
        ),
        Positioned(
          bottom: -40,
          left: -60,
          child: _circle(200, SplashColors.faintGreen),
        ),
        Positioned(
          top: 180,
          left: -30,
          child: _circle(120, SplashColors.limeFaint),
        ),
      ],
    );
  }

  Widget _circle(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
