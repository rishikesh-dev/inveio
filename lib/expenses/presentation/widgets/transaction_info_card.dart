import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/presentation/widgets/section_title_row.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A card displaying payment method, status, and notes for a transaction.
class TransactionInfoCard extends StatelessWidget {
  const TransactionInfoCard({super.key, this.transaction});

  /// The transaction to display. When null, shows placeholder info.
  final TransactionEntity? transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return AppCard(
      padding: const EdgeInsets.all(18),
      color: Theme.of(context).cardColor,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleRow(title: 'Transaction Info'),
          const SizedBox(height: 18),
          if (t?.paymentMode != null) ...[
            const DetailInfoLabel('Payment Method'),
            const SizedBox(height: 8),
            Row(
              children: [
                PaymentMethodPill(mode: t!.paymentMode!),
                const SizedBox(width: 14),
                Text(
                  t.paymentMode == PaymentMode.cash
                      ? 'Cash'
                      : t.paymentMode == PaymentMode.upi
                      ? 'UPI'
                      : 'Card',
                  style: const TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          if (t?.vendorName != null || t?.clientName != null) ...[
            DetailInfoLabel(t!.vendorName != null ? 'Vendor' : 'Client'),
            const SizedBox(height: 8),
            Text(
              t.vendorName ?? t.clientName ?? '',
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
          ],
          const DetailInfoLabel('Status'),
          const SizedBox(height: 8),
          const AccentChip(
            label: 'Completed',
            icon: LucideIcons.badgeCheck,
            compact: true,
          ),
          if (t != null && t.description.isNotEmpty) ...[
            const SizedBox(height: 18),
            const DetailInfoLabel('Notes'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorderSoft),
                color: AppColors.darkShell,
              ),
              child: Text(
                t.description,
                style: const TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A styled section label used within transaction detail cards.
class DetailInfoLabel extends StatelessWidget {
  const DetailInfoLabel(this.label, {super.key});

  /// The label text to display.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/// A small pill-shaped badge displaying the payment mode.
class PaymentMethodPill extends StatelessWidget {
  const PaymentMethodPill({super.key, required this.mode});

  /// The payment mode to display.
  final PaymentMode mode;

  @override
  Widget build(BuildContext context) {
    final label = switch (mode) {
      PaymentMode.cash => 'CASH',
      PaymentMode.upi => 'UPI',
      PaymentMode.card => 'CARD',
      PaymentMode.bank => 'BANK',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.darkBorderSoft,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.darkTextMuted),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 13,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
