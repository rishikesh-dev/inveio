import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CashFlowCard extends StatelessWidget {
  const CashFlowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      padding: EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title('Cash Flow Summary'),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _CashCard(label: 'Total Inflow', value: '85,000')),
              SizedBox(width: 12),
              Expanded(child: _CashCard(label: 'Total Outflow', value: '32,400')),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Net Positive',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '+₹ 52,600',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _ProgressBar(fillFraction: 0.72),
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
  final String value;

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
              const Text('₹', style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 21, fontWeight: FontWeight.w800),
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
            Expanded(flex: (fillFraction * 100).round(), child: const ColoredBox(color: AppColors.primary)),
            Expanded(flex: ((1 - fillFraction) * 100).round(), child: const ColoredBox(color: AppColors.darkBorderSoft)),
          ],
        ),
      ),
    );
  }
}
