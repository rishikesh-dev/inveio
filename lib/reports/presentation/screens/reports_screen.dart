import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/reports/presentation/widgets/cash_flow_card.dart';
import 'package:inveio/reports/presentation/widgets/category_card.dart';
import 'package:inveio/reports/presentation/widgets/monthly_spend_card.dart';
import 'package:inveio/reports/presentation/widgets/reports_header.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'Apr 2025';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _pickPeriod() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (context) {
        const periods = ['Apr 2025', 'May 2025', 'Jun 2025'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final period in periods)
                  AccentChip(
                    label: period,
                    selected: _period == period,
                    icon: LucideIcons.calendar,
                    compact: true,
                    onTap: () {
                      setState(() => _period = period);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReportsHeader(period: _period, onPeriodTap: _pickPeriod).toAnimatedEntrance(),
                  const SizedBox(height: 22),
                  const MonthlySpendCard().toAnimatedEntrance(delay: const Duration(milliseconds: 80)),
                  const SizedBox(height: 18),
                  const CategoryCard().toAnimatedEntrance(delay: const Duration(milliseconds: 150)),
                  const SizedBox(height: 18),
                  const CashFlowCard().toAnimatedEntrance(delay: const Duration(milliseconds: 220)),
                  const SizedBox(height: 20),
                  NeonButton(
                    label: 'Export PDF',
                    icon: LucideIcons.fileText,
                    onPressed: () => _showMessage('PDF export started'),
                    height: 50,
                  ).toAnimatedEntrance(delay: const Duration(milliseconds: 280)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
