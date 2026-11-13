import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/transaction_card_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// The main screen that displays expense transactions grouped by date.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const AppBarWidget(
            title: 'Expenses',
            titleStyle: TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24).toSliver(),
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
                  child: SizedBox(
                    height: 200,
                    child: Center(child: Text('No expenses yet')),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: state.latest.latestExpenses.length,
                itemBuilder: (context, index) {
                  final expense = state.latest.latestExpenses[index];
                  return TransactionCardWidget(
                    transactionUid: expense.uid,
                    transactionLocalId: expense.localId,
                    title:
                        expense.vendorName ??
                        expense.category ??
                        expense.description,
                    onTap: () {
                      final localId = expense.localId;
                      if (localId == null) return;
                      context.pushNamed(
                        RouterConstants.transactionDetails,
                        extra: localId,
                      );
                    },
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
