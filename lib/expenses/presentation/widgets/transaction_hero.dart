import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TransactionHero extends StatelessWidget {
  final TransactionEntity? transaction;
  const TransactionHero({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    return Column(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.darkCardAlt,
          child: Icon(
            LucideIcons.coffee,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          t?.vendorName ?? t?.clientName ?? t?.description ?? 'title',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t != null
              ? DateFormat('MMM d, y - hh:mm a').format(t.date)
              : 'Oct 24, 2023 - 09:42 AM',
          style: const TextStyle(
            color: AppColors.darkTextSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 22),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            t != null
                ? CurrencyFormatter.compact(t.totalAmount)
                : '₹850.00',
            style: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 20),
        AccentChip(
          label: t?.category?.toUpperCase() ?? 'FOOD & DINING',
          icon: LucideIcons.utensils,
          compact: true,
        ),
      ],
    );
  }
}