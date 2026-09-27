import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// Decorative receipt card decorations on the splash screen.
class ReceiptCards extends StatelessWidget {
  /// The vertical offset applied by the floating animation.
  final double floatOffset;

  const ReceiptCards({super.key, required this.floatOffset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 92 + floatOffset * 0.7,
          right: 28,
          child: Transform.rotate(
            angle: 0.07,
            child: _card('GST 18% · ₹468'),
          ),
        ),
        Positioned(
          bottom: 185 - floatOffset * 0.9,
          left: 22,
          child: Transform.rotate(
            angle: -0.05,
            child: _card('Invoice #042 · filed'),
          ),
        ),
      ],
    );
  }

  Widget _card(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: SplashColors.lightGreen, width: 1.5),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: SplashColors.midGreen,
      ),
    ),
  );
}
