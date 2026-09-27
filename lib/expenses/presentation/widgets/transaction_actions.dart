import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// A bottom action bar with Edit and Delete buttons for the transaction
/// detail screen.
class DetailActions extends StatelessWidget {
  final TransactionEntity? transaction;

  const DetailActions({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.darkShell,
        border: Border(top: BorderSide(color: AppColors.darkBorderSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.pushNamed(
                  RouterConstants.addExpense,
                  extra: transaction,
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: AppColors.darkTextPrimary,
                side: const BorderSide(color: AppColors.darkBorderSoft),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Edit',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                if (transaction?.localId == null) return;
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.darkCard,
                    title: const Text(
                      'Delete transaction?',
                      style: TextStyle(color: AppColors.darkTextPrimary),
                    ),
                    content: const Text(
                      'This removes the transaction from the local list.',
                      style: TextStyle(color: AppColors.darkTextSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  context
                      .read<TransactionBloc>()
                      .add(DeleteTransaction(transaction!.localId!));
                  Navigator.of(context).maybePop();
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
                foregroundColor: const Color(0xFFFFB9B9),
                side: const BorderSide(color: Color(0xFFFFB9B9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
