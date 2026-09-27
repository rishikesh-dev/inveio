import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MonthlySpendCard extends StatelessWidget {
  const MonthlySpendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title('Monthly Spend'),
          SizedBox(height: 8),
          _Subtitle('₹145,200 total this year'),
          SizedBox(height: 22),
          SizedBox(height: 160, child: _LineChart()),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      painter: _LineChartPainter(),
      child: SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.darkBorder
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];

    for (var i = 0; i < 5; i++) {
      canvas.drawLine(Offset(0, size.height * (0.12 + i * 0.18)), Offset(size.width, size.height * (0.12 + i * 0.18)), gridPaint);
    }

    for (var i = 0; i < months.length; i++) {
      textPainter.text = TextSpan(
        text: months[i],
        style: TextStyle(
          color: i == 3 ? AppColors.primary : AppColors.darkTextSecondary,
          fontSize: 11,
          fontWeight: i == 3 ? FontWeight.w900 : FontWeight.w500,
        ),
      );
      textPainter.layout();
      final x = (size.width / (months.length - 1)) * i - textPainter.width / 2;
      textPainter.paint(canvas, Offset(x.clamp(0, size.width), size.height - 22));
    }

    final points = <Offset>[
      Offset(0, size.height * 0.62),
      Offset(size.width * 0.2, size.height * 0.46),
      Offset(size.width * 0.4, size.height * 0.52),
      Offset(size.width * 0.6, size.height * 0.28),
      Offset(size.width * 0.8, size.height * 0.36),
      Offset(size.width, size.height * 0.18),
    ];

    final fillPath = Path()..moveTo(points.first.dx, size.height - 26);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath..lineTo(points.last.dx, size.height - 26)..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withValues(alpha: 0.26), AppColors.primary.withValues(alpha: 0.02)],
        ).createShader(Offset.zero & size),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    final dotPaint = Paint()..color = AppColors.darkBg;
    final dotBorderPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final point in points) {
      canvas..drawCircle(point, 4, dotPaint)..drawCircle(point, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
