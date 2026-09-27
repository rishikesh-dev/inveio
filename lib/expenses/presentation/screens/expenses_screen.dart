import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/presentation/widgets/transaction_card_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:inveio/expenses/presentation/widgets/expense_widgets.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The main screen that displays expense transactions grouped by date,
/// with filter chips and a search box.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  String _filter = 'All';

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder: (context) {
        const filters = ['All', 'GST only', 'Travel', 'Meals', 'Equipment'];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Wrap(
              runSpacing: 10,
              spacing: 10,
              children: [
                for (final filter in filters)
                  AccentChip(
                    label: filter,
                    selected: _filter == filter,
                    onTap: () {
                      setState(() => _filter = filter);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(content: Text('Filter applied: $filter')),
                        );
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
      body: CustomScrollView(
        slivers: [
          AppBarWidget(
            title: 'Expenses',
            titleStyle: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            actions: [ExpenseFilterButton(onTap: _openFilters)],
          ),
          const SizedBox(height: 24).toSliver(),
          const TextFieldWidget(
            prefix: Icon(
              LucideIcons.search,
              color: AppColors.darkTextSecondary,
              size: 22,
            ),
            hintText: 'Search transactions...',
          ).withPadding(const EdgeInsets.symmetric(horizontal: 12)).toSliver(),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state.latest.isLoadingLatest) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (state.latest.latestError != null) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(state.latest.latestError!),
                  ),
                );
              }
              if (state.latest.latestExpenses.isEmpty) {
                return const SliverToBoxAdapter(
                  child: SizedBox(height: 200,
                    child: Center(child: Text('No expenses yet')),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: state.latest.latestExpenses.length,
                itemBuilder: (context, index) {
                  final expense = state.latest.latestExpenses[index];
                  return TransactionCardWidget(
                    title:
                        expense.vendorName ??
                        expense.category ??
                        expense.description,
                    onTap: () => context.pushNamed(
                      RouterConstants.transactionDetails,
                      extra: expense.id,
                    ),
                    icon: Icons.currency_rupee_sharp,
                    subTitle:
                        '${DateFormat('MMM d').format(expense.date)}'
                        ' - ${expense.category ?? 'Expense'}',
                    mainAmount: expense.totalAmount,
                    subAmount: expense.cgst + expense.sgst + expense.igst,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
