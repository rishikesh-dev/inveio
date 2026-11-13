import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/currency_formatter.dart';
import 'package:inveio/home/presentation/widgets/dashboard_metric_block.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A card that displays the total spend summary for the current month,
/// including daily average, budget left, and the overall spend amount.
class DashboardSpendSummaryCard extends StatelessWidget {
  const DashboardSpendSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final expenses = state.latest.latestExpenses;
        final totalSpend = expenses.fold<double>(
          0,
          (sum, e) => sum + e.totalAmount,
        );
        final totalTax = expenses.fold<double>(
          0,
          (sum, e) => sum + e.cgst + e.sgst + e.igst,
        );

        final daysInMonth = DateTime.now().day;
        final dailyAvg = daysInMonth > 0 ? totalSpend / daysInMonth : 0.0;

        return AppCard(
          padding: const EdgeInsets.all(20),
          color: AppColors.darkSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL SPEND THIS MONTH',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  CurrencyFormatter.compact(totalSpend),
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.darkBorder),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DashboardMetricBlock(
                      label: 'Daily Average',
                      value: CurrencyFormatter.compact(dailyAvg),
                    ),
                  ),
                  const SizedBox(
                    height: 42,
                    child: VerticalDivider(color: AppColors.darkBorder),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: DashboardMetricBlock(
                        label: 'GST Total',
                        value: CurrencyFormatter.compact(totalTax),
                        accent: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
