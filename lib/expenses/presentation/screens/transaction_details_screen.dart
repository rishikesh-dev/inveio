import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/expenses/presentation/widgets/gst_breakdown_card.dart';
import 'package:inveio/expenses/presentation/widgets/transaction_actions.dart';
import 'package:inveio/expenses/presentation/widgets/transaction_hero.dart';
import 'package:inveio/expenses/presentation/widgets/transaction_info_card.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen that displays the full details of a transaction.
class TransactionDetailsScreen extends StatefulWidget {
  final String expenseId;
  const TransactionDetailsScreen({super.key, required this.expenseId});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
      TransactionDetailsRequested(widget.expenseId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            final transaction = state.selectedTransaction;
            return CustomScrollView(
              slivers: [
                AppBarWidget(
                  actions: [
                    PopupMenuButton<String>(
                      color: AppColors.darkCard,
                      icon: const Icon(
                        LucideIcons.ellipsisVertical,
                        color: AppColors.darkTextPrimary,
                      ),
                      onSelected: (value) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(SnackBar(content: Text(value)));
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'Receipt shared',
                          child: Text('Share'),
                        ),
                        PopupMenuItem(
                          value: 'Marked as reimbursable',
                          child: Text('Mark reimbursable'),
                        ),
                      ],
                    ),
                  ],
                ),

                SliverFillRemaining(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(10, 18, 10, 88),
                    child: Column(
                      children: [
                        TransactionHero(
                          transaction: transaction,
                        ).toAnimatedEntrance(),
                        const SizedBox(height: 24),
                        if (transaction != null)
                          GstBreakdownCard(
                            transaction: transaction,
                          ).toAnimatedEntrance(
                            delay: const Duration(milliseconds: 80),
                          )
                        else
                          const GstBreakdownCard().toAnimatedEntrance(
                            delay: const Duration(milliseconds: 80),
                          ),
                        const SizedBox(height: 16),
                        TransactionInfoCard(transaction: transaction).toAnimatedEntrance(
                          delay: const Duration(milliseconds: 150),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) =>
            DetailActions(transaction: state.selectedTransaction),
      ),
    );
  }
}
