import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CashFlowCard extends StatelessWidget {
  const CashFlowCard({
    super.key,
    required this.inflow,
    required this.outflow,
  });

  final double inflow;
  final double outflow;

  @override
  Widget build(BuildContext context) {
    final net = inflow - outflow;
    final isPositive = net >= 0;
    final total = inflow + outflow;
    final fillFraction = total == 0 ? 0.0 : inflow / total;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title('Cash Flow Summary'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _CashCard(label: 'Total Inflow', value: inflow),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CashCard(label: 'Total Outflow', value: outflow),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  isPositive ? 'Net Positive' : 'Net Negative',
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                CurrencyFormatter.compact(
                  net.abs(),
                  includeSign: true,
                  isExpense: !isPositive,
                ),
                style: const TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressBar(fillFraction: fillFraction),
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

class _CashCard extends StatelessWidget {
  const _CashCard({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkMutedPanel,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -12,
            child: Icon(
              LucideIcons.chartNoAxesColumnIncreasing,
              color: AppColors.darkTextMuted.withValues(alpha: 0.25),
              size: 48,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '₹',
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.compact(value).replaceFirst('₹', ''),
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.fillFraction});

  final double fillFraction;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            Expanded(
              flex: (fillFraction * 100).round(),
              child: const ColoredBox(color: AppColors.primary),
            ),
            Expanded(
              flex: ((1 - fillFraction) * 100).round(),
              child: const ColoredBox(color: AppColors.darkBorderSoft),
            ),
          ],
        ),
      ),
    );
  }
}
