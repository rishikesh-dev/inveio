import 'package:flutter/material.dart';

import 'splash_colors.dart';

/// Animated coin decorations floating around the splash screen.
class FloatingCoins extends StatelessWidget {
  /// The vertical offset applied by the floating animation.
  final double floatOffset;

  const FloatingCoins({super.key, required this.floatOffset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 110 + floatOffset,
          left: 44,
          child: _coin(
            symbol: '₹',
            bg: SplashColors.lime,
            fg: SplashColors.deepGreen,
            size: 44,
          ),
        ),
        Positioned(
          top: 160 + floatOffset * 0.8,
          right: 50,
          child: _coin(
            symbol: '₹',
            bg: SplashColors.green,
            fg: Colors.white,
            size: 34,
          ),
        ),
        Positioned(
          bottom: 220 - floatOffset * 0.6,
          right: 40,
          child: _coin(
            symbol: '\$',
            bg: SplashColors.gold,
            fg: SplashColors.goldDark,
            size: 28,
          ),
        ),
        Positioned(
          bottom: 260 + floatOffset * 0.5,
          left: 36,
          child: _dashedCoin(symbol: '₹', size: 32),
        ),
      ],
    );
  }

  Widget _coin({
    required String symbol,
    required Color bg,
    required Color fg,
    required double size,
  }) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Text(
      symbol,
      style: TextStyle(
        fontSize: size * 0.42,
        fontWeight: FontWeight.w900,
        color: fg,
      ),
    ),
  );

  Widget _dashedCoin({required String symbol, required double size}) =>
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: SplashColors.greenTranslucent,
          shape: BoxShape.circle,
          border: Border.all(
            color: SplashColors.green,
            width: 2,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: CustomPaint(
          painter: _DashedCirclePainter(color: SplashColors.green),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w900,
                color: SplashColors.green,
              ),
            ),
          ),
        ),
      );
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;
    const dashCount = 12;
    const arcLength = 2 * 3.14159 / dashCount;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * arcLength;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        arcLength * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
