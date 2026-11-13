import 'dart:math' as math;

import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.total,
    required this.categories,
  });

  final double total;
  final Map<String, double> categories;

  static const _colors = [
    AppColors.primary,
    Color(0xFFC8CBB1),
    Color(0xFFA7AD91),
    AppColors.darkMutedPanel,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = categories.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(3).toList();
    final other = entries
        .skip(3)
        .fold<double>(0, (sum, entry) => sum + entry.value);

    final labels = <String>[for (final entry in top) entry.key];
    final values = <double>[for (final entry in top) entry.value];
    if (other > 0) {
      labels.add('Other');
      values.add(other);
    }
    final fractions = total <= 0
        ? const <double>[]
        : [for (final value in values) value / total];
    final colors = _colors.take(labels.length).toList();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title('By Category'),
          const SizedBox(height: 22),
          if (fractions.isEmpty)
            const SizedBox(
              height: 172,
              child: Center(child: _Subtitle('No expense data')),
            )
          else ...[
            Center(
              child: SizedBox(
                width: 172,
                height: 172,
                child: _DonutChart(
                  total: total,
                  fractions: fractions,
                  colors: colors,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(child: _Legend(labels: labels, colors: colors)),
          ],
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

class _DonutChart extends StatelessWidget {
  const _DonutChart({
    required this.total,
    required this.fractions,
    required this.colors,
  });

  final double total;
  final List<double> fractions;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          painter: _DonutPainter(fractions: fractions, colors: colors),
          child: const SizedBox.expand(),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _Subtitle('TOTAL'),
            const SizedBox(height: 8),
            _Amount(CurrencyFormatter.compact(total)),
          ],
        ),
      ],
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
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.fractions, required this.colors});

  final List<double> fractions;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.13;
    var start = -math.pi / 2;

    for (var i = 0; i < fractions.length; i++) {
      final sweep = math.pi * 2 * fractions[i];
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, paint);
      start += sweep + 0.045;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.fractions != fractions || oldDelegate.colors != colors;
}

class _Legend extends StatelessWidget {
  const _Legend({required this.labels, required this.colors});

  final List<String> labels;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 8,
      children: [
        for (var i = 0; i < labels.length; i++)
          _LegendItem(label: labels[i], color: colors[i]),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 5, backgroundColor: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
