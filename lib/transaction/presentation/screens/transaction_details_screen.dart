import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/expenses/presentation/widgets/gst_breakdown_card.dart';
import 'package:inveio/expenses/presentation/widgets/transaction_actions.dart';
import 'package:inveio/expenses/presentation/widgets/transaction_hero.dart';
import 'package:inveio/expenses/presentation/widgets/transaction_info_card.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

/// Screen that displays the full details of a transaction.
class TransactionDetailsScreen extends StatefulWidget {
  final int? localId;
  const TransactionDetailsScreen({super.key, required this.localId});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final localId = widget.localId;
    if (localId == null) return;
    context.read<TransactionBloc>().add(TransactionDetailsRequested(localId));
  }

  /// Shares the invoice PDF when available, otherwise a text summary.
  Future<void> _shareTransaction(TransactionEntity? transaction) async {
    if (transaction == null) return;

    final pdfPath = transaction.pdfPath;
    if (transaction.type == TransactionType.invoice && pdfPath != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfPath, mimeType: 'application/pdf')],
          subject: 'Invoice',
        ),
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(text: _textSummary(transaction)),
    );
  }

  /// Plain-text summary of a transaction: vendor, date, amount and GST.
  String _textSummary(TransactionEntity transaction) {
    final isInvoice = transaction.type == TransactionType.invoice;
    final party = isInvoice
        ? transaction.clientName
        : transaction.vendorName;
    final buffer = StringBuffer(isInvoice ? 'Invoice' : 'Expense');
    if (party != null && party.isNotEmpty) {
      buffer.write('\nVendor: $party');
    }
    buffer
      ..write('\nDate: ${DateFormat.yMMMd().format(transaction.date)}')
      ..write('\nAmount: ${transaction.totalAmount.toStringAsFixed(2)}')
      ..write(
        '\nGST (${transaction.gstSlab}%): '
        'CGST ${transaction.cgst.toStringAsFixed(2)}, '
        'SGST ${transaction.sgst.toStringAsFixed(2)}, '
        'IGST ${transaction.igst.toStringAsFixed(2)}',
      );
    return buffer.toString();
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
                        if (value == 'share') {
                          _shareTransaction(transaction);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'share',
                          child: Text('Share'),
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
                        TransactionInfoCard(
                          transaction: transaction,
                        ).toAnimatedEntrance(
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
