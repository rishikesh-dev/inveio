import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/reports/presentation/widgets/cash_flow_card.dart';
import 'package:inveio/reports/presentation/widgets/category_card.dart';
import 'package:inveio/reports/presentation/widgets/monthly_spend_card.dart';
import 'package:inveio/reports/presentation/widgets/reports_header.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionBloc>().add(const AllTransactionsRequested());
    });
  }

  List<DateTime> _availableMonths(List<TransactionEntity> transactions) {
    final months = <DateTime>{
      for (final transaction in transactions)
        DateTime(transaction.date.year, transaction.date.month),
    }.toList()
      ..sort((a, b) => b.compareTo(a));
    return months;
  }

  void _pickPeriod(List<DateTime> months, DateTime? selectedMonth) {
    if (months.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final month in months)
                  AccentChip(
                    label: DateFormat('MMM yyyy').format(month),
                    selected: selectedMonth == month,
                    icon: LucideIcons.calendar,
                    compact: true,
                    onTap: () {
                      setState(() => _selectedMonth = month);
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
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          final transactions = state.latest.latestExpenses;
          final months = _availableMonths(transactions);
          final selectedMonth = months.isEmpty
              ? null
              : (_selectedMonth != null && months.contains(_selectedMonth)
                    ? _selectedMonth
                    : months.first);

          final periodTransactions = selectedMonth == null
              ? const <TransactionEntity>[]
              : transactions
                    .where(
                      (transaction) =>
                          transaction.date.year == selectedMonth.year &&
                          transaction.date.month == selectedMonth.month,
                    )
                    .toList();
          final expenses = periodTransactions
              .where(
                (transaction) => transaction.type == TransactionType.expense,
              )
              .toList();
          final invoices = periodTransactions
              .where(
                (transaction) => transaction.type == TransactionType.invoice,
              )
              .toList();

          final expenseTotal = _sumAmounts(expenses);
          final invoiceTotal = _sumAmounts(invoices);
          final yearExpenseTotal = _sumAmounts(
            transactions.where(
              (transaction) =>
                  transaction.type == TransactionType.expense &&
                  transaction.date.year == selectedMonth?.year,
            ),
          );

          final chartMonths = selectedMonth == null
              ? const <DateTime>[]
              : [
                  for (var i = 5; i >= 0; i--)
                    DateTime(selectedMonth.year, selectedMonth.month - i),
                ];
          final chartValues = [
            for (final month in chartMonths)
              _sumAmounts(
                transactions.where(
                  (transaction) =>
                      transaction.type == TransactionType.expense &&
                      transaction.date.year == month.year &&
                      transaction.date.month == month.month,
                ),
              ),
          ];

          final categories = <String, double>{};
          for (final expense in expenses) {
            final category = expense.category?.trim();
            final label = category == null || category.isEmpty
                ? 'Uncategorized'
                : category;
            categories[label] =
                (categories[label] ?? 0) + expense.totalAmount;
          }

          final periodLabel = DateFormat(
            'MMM yyyy',
          ).format(selectedMonth ?? DateTime.now());

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReportsHeader(
                        period: periodLabel,
                        onPeriodTap: () => _pickPeriod(months, selectedMonth),
                      ).toAnimatedEntrance(),
                      const SizedBox(height: 22),
                      if (state.latest.isLoadingLatest && transactions.isEmpty)
                        const SizedBox(
                          height: 240,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.latest.latestError != null)
                        _ErrorState(
                          message: state.latest.latestError!,
                          onRetry: () {
                            setState(() => _selectedMonth = null);
                            context.read<TransactionBloc>().add(
                              const AllTransactionsRequested(),
                            );
                          },
                        ).toAnimatedEntrance(
                          delay: const Duration(milliseconds: 80),
                        )
                      else if (transactions.isEmpty)
                        const _EmptyState().toAnimatedEntrance(
                          delay: const Duration(milliseconds: 80),
                        )
                      else ...[
                        MonthlySpendCard(
                          totalThisYear: yearExpenseTotal,
                          monthLabels: [
                            for (final month in chartMonths)
                              DateFormat('MMM').format(month),
                          ],
                          monthValues: chartValues,
                          highlightedIndex: chartMonths.length - 1,
                        ).toAnimatedEntrance(
                          delay: const Duration(milliseconds: 80),
                        ),
                        const SizedBox(height: 18),
                        CategoryCard(
                          total: expenseTotal,
                          categories: categories,
                        ).toAnimatedEntrance(
                          delay: const Duration(milliseconds: 150),
                        ),
                        const SizedBox(height: 18),
                        CashFlowCard(
                          inflow: invoiceTotal,
                          outflow: expenseTotal,
                        ).toAnimatedEntrance(
                          delay: const Duration(milliseconds: 220),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.chartArea,
              color: AppColors.darkTextMuted,
              size: 42,
            ),
            SizedBox(height: 12),
            Text(
              'No reports yet',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Add an expense or invoice to see your insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.circleAlert,
                color: AppColors.darkTextSecondary,
                size: 42,
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to load reports',
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              NeonButton(
                label: 'Retry',
                icon: LucideIcons.refreshCw,
                onPressed: onRetry,
                height: 44,
              ),
            ],
          ),
        ),
      ),
      );
  }
}

double _sumAmounts(Iterable<TransactionEntity> transactions) =>
    transactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.totalAmount,
    );
