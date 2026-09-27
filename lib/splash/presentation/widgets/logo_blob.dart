import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// The animated app logo shape with a winking eye effect.
class LogoBlob extends StatelessWidget {
  /// The scale factor for the winking dot animation.
  final double winkScale;

  const LogoBlob({super.key, required this.winkScale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: SplashColors.green,
              borderRadius: BorderRadius.circular(28),
            ),
            alignment: Alignment.center,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -2,
                  height: 1,
                ),
                children: [
                  TextSpan(text: 'In'),
                  TextSpan(
                    text: 'v',
                    style: TextStyle(color: SplashColors.lime),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -6,
            right: -6,
            child: Transform.scale(
              scaleY: winkScale,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: SplashColors.lime,
                  shape: BoxShape.circle,
                  border: Border.all(color: SplashColors.bg, width: 3),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: SplashColors.deepGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
