import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/currency_formatter.dart';
import 'package:inveio/expenses/presentation/widgets/transaction_tax_lines.dart';
import 'package:flutter/material.dart';

/// A card that displays the CGST, SGST, and total tax breakdown for a
/// transaction.
class GstBreakdownCard extends StatelessWidget {
  final TransactionEntity? transaction;
  const GstBreakdownCard({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final cgst = t != null ? CurrencyFormatter.compact(t.cgst) : '₹ 35.80';
    final sgst = t != null ? CurrencyFormatter.compact(t.sgst) : '₹ 35.80';
    final total = t != null
        ? CurrencyFormatter.compact(t.cgst + t.sgst + t.igst)
        : '₹ 71.60';

    return AppCard(
      padding: const EdgeInsets.all(18),
      color: AppColors.darkCardAlt,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          TaxLine(label: 'CGST', percent: '${t?.gstSlab ?? 9}%', amount: cgst),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.darkBorderSoft),
          ),
          TaxLine(label: 'SGST', percent: '${t?.gstSlab ?? 9}%', amount: sgst),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.darkBorderSoft),
          ),
          TotalLine(label: 'Total Tax', amount: total),
        ],
      ),
    );
  }
}
