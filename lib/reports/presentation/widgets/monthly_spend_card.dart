import 'dart:math' as math;

import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class MonthlySpendCard extends StatelessWidget {
  const MonthlySpendCard({
    super.key,
    required this.totalThisYear,
    required this.monthLabels,
    required this.monthValues,
    required this.highlightedIndex,
  });

  final double totalThisYear;
  final List<String> monthLabels;
  final List<double> monthValues;
  final int highlightedIndex;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title('Monthly Spend'),
          const SizedBox(height: 8),
          _Subtitle(
            '${CurrencyFormatter.compact(totalThisYear)} total this year',
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 160,
            child: _LineChart(
              labels: monthLabels,
              values: monthValues,
              highlightedIndex: highlightedIndex,
            ),
          ),
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
  const _LineChart({
    required this.labels,
    required this.values,
    required this.highlightedIndex,
  });

  final List<String> labels;
  final List<double> values;
  final int highlightedIndex;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineChartPainter(
        labels: labels,
        values: values,
        highlightedIndex: highlightedIndex,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.labels,
    required this.values,
    required this.highlightedIndex,
  });

  final List<String> labels;
  final List<double> values;
  final int highlightedIndex;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.darkBorder
      ..strokeWidth = 1;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(0, size.height * (0.12 + i * 0.18)),
        Offset(size.width, size.height * (0.12 + i * 0.18)),
        gridPaint,
      );
    }

    for (var i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: i == highlightedIndex
              ? AppColors.primary
              : AppColors.darkTextSecondary,
          fontSize: 11,
          fontWeight: i == highlightedIndex
              ? FontWeight.w900
              : FontWeight.w500,
        ),
      );
      textPainter.layout();
      final x = labels.length == 1
          ? size.width / 2 - textPainter.width / 2
          : (size.width / (labels.length - 1)) * i - textPainter.width / 2;
      textPainter.paint(
        canvas,
        Offset(x.clamp(0, size.width), size.height - 22),
      );
    }

    if (values.isEmpty) return;

    final maxValue = values.reduce(math.max);
    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          values.length == 1
              ? size.width / 2
              : (size.width / (values.length - 1)) * i,
          size.height *
              (0.62 - (maxValue == 0 ? 0 : values[i] / maxValue) * 0.44),
        ),
    ];

    final fillPath = Path()..moveTo(points.first.dx, size.height - 26);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, size.height - 26)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.26),
            AppColors.primary.withValues(alpha: 0.02),
          ],
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
      canvas
        ..drawCircle(point, 4, dotPaint)
        ..drawCircle(point, 4, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.labels != labels ||
      oldDelegate.values != values ||
      oldDelegate.highlightedIndex != highlightedIndex;
}
