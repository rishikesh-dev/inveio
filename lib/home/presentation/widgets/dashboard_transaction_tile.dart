import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A tile widget that displays a single transaction from the dashboard.
class TransactionTileWidget extends StatefulWidget {
  /// Creates a [TransactionTileWidget] for the given [transaction].
  const TransactionTileWidget({
    super.key,
    required this.transaction,
    required this.showDivider,
    this.onTap,
  });

  /// The transaction entity to display.
  final TransactionEntity transaction;
  /// Whether to show a divider below this tile.
  final bool showDivider;
  /// Callback when the tile is tapped.
  final VoidCallback? onTap;

  @override
  /// Creates the mutable state for [TransactionTileWidget].
  State<TransactionTileWidget> createState() => _TransactionTileStateWidget();
}

class _TransactionTileStateWidget extends State<TransactionTileWidget> {
  bool _pressed = false;

  @override
  /// Builds the animated transaction tile with description, category, and amount.
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AppCard(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 10),
          color: _pressed ? AppColors.darkCardAlt : AppColors.darkSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  // CircleAvatar(
                  //   radius: 21,
                  //   // backgroundColor: widget.transaction.
                  //   //     ? AppColors.incomeAlpha
                  //   //     : AppColors.darkMutedPanel,
                  //   child: Icon(
                  //     widget.transaction.,
                  //     color: widget.transaction.isIncome
                  //         ? AppColors.primary
                  //         : AppColors.darkTextSecondary,
                  //     size: 19,
                  //   ),
                  // ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.transaction.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.darkTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.transaction.category ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.transaction.totalAmount.toString(),
                    style: TextStyle(
                      color:
                          widget.transaction.paymentStatus == PaymentStatus.paid
                          ? AppColors.primary
                          : AppColors.darkTextPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
