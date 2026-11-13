import 'package:go_router/go_router.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/presentation/widgets/Menus/app_menu_item.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum TransactionMenuAction { edit, duplicate, share, sharePdf, print, details, delete }

/// A card widget that displays a transaction summary with title, subtitle, and amounts.
class TransactionCardWidget extends StatefulWidget {
  /// Creates a [TransactionCardWidget] with the given transaction details.
  const TransactionCardWidget({
    super.key,
    required this.transactionUid,
    this.transactionLocalId,
    this.onTap,
    required this.title,
    required this.subTitle,
    required this.mainAmount,
    required this.subAmount,
    this.icon,
    this.iconColor,
    this.subTitleTrailing,
    this.subAmountPrefix = '',
    this.amountFractionDigits,
    this.onEdit,
    this.invoiceActions = false,
    this.onMenuAction,
  });

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Local Isar id of the transaction, used to open the edit route.
  final int? transactionLocalId;

  final String transactionUid;

  /// Primary title of the transaction.
  final String title;

  /// Subtitle of the transaction.
  final String subTitle;

  /// Main amount displayed prominently.
  final double mainAmount;

  /// Secondary amount displayed below the main amount.
  final double subAmount;

  /// Optional icon displayed on the left.
  final IconData? icon;

  /// Color of [icon]. Defaults to green.
  final Color? iconColor;

  /// Optional widget shown beside [subTitle], such as a status chip.
  final Widget? subTitleTrailing;

  /// Text prepended to [subAmount] (for example `GST: `).
  final String subAmountPrefix;

  /// Number of decimal places used for both amounts. Defaults to the
  /// platform's default `double.toString()` formatting.
  final int? amountFractionDigits;

  /// Overrides the default edit navigation. Useful for non-expense
  /// transactions such as invoices.
  final VoidCallback? onEdit;

  /// When true, shows the "Share PDF" and "Print" menu items. Only invoice
  /// cards should pass `true`; expense cards leave this as `false`.
  final bool invoiceActions;

  final ValueChanged<TransactionMenuAction>? onMenuAction;

  @override
  /// Creates the mutable state for [TransactionCardWidget].
  State<TransactionCardWidget> createState() => _TransactionCardWidgetState();
}

class _TransactionCardWidgetState extends State<TransactionCardWidget> {
  bool _pressed = false;

  Future<void> _showPopupMenu(BuildContext context, Offset position) async {
    final action = await AppContextMenu.show<TransactionMenuAction>(
      context: context,
      position: position,
      items: [
        AppMenuItem(
          value: TransactionMenuAction.edit,
          label: 'Edit',
          icon: Icons.edit_outlined,
          onTap: () {
            final onEdit = widget.onEdit;
            if (onEdit != null) {
              onEdit();
              return;
            }
            final localId = widget.transactionLocalId;
            if (localId == null) return;
            context.pushNamed(
              RouterConstants.editExpense,
              pathParameters: {'id': localId.toString()},
            );
          },
        ),
        AppMenuItem(
          value: TransactionMenuAction.duplicate,
          label: 'Duplicate',
          icon: Icons.copy_outlined,
          onTap: () {},
        ),
        AppMenuItem(
          value: TransactionMenuAction.share,
          label: 'Share',
          icon: Icons.share_outlined,
          onTap: () {},
        ),
        if (widget.invoiceActions) ...[
          AppMenuItem(
            value: TransactionMenuAction.sharePdf,
            label: 'Share PDF',
            icon: Icons.picture_as_pdf_outlined,
            onTap: () {},
          ),
          AppMenuItem(
            value: TransactionMenuAction.print,
            label: 'Print',
            icon: Icons.print_outlined,
            onTap: () {},
          ),
        ],
        AppMenuItem(
          value: TransactionMenuAction.details,
          label: 'View details',
          icon: Icons.info_outline,
          onTap: () {
            final localId = widget.transactionLocalId;
            if (localId == null) return;
            context.pushNamed(
              RouterConstants.transactionDetails,
              extra: localId,
            );
          },
        ),
        AppMenuItem(
          value: TransactionMenuAction.delete,
          label: 'Delete',
          icon: Icons.delete_outline,
          onTap: () {},
          isDestructive: true,
          showDividerBefore: true,
        ),
      ],
    );

    if (!mounted || action == null) return;

    widget.onMenuAction?.call(action);
  }

  @override
  /// Builds the animated transaction card with tap feedback.
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onLongPressStart: (details) {
          _showPopupMenu(context, details.globalPosition);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.only(
            left: 15.0,
            right: 25.0,
            top: 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: _pressed
                ? Theme.of(context).cardColor.withAlpha(80)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: Theme.of(context).focusColor,
                ),
                child: Icon(
                  widget.icon,
                  size: 20.0,
                  color: widget.iconColor ?? Colors.green,
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: AppConstants.secondaryFontFamily,
                        letterSpacing: 0.1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            widget.subTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppConstants.secondaryFontFamily,
                              letterSpacing: 0.1,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                        if (widget.subTitleTrailing != null) ...[
                          const SizedBox(width: 8),
                          widget.subTitleTrailing!,
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatAmount(widget.mainAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppConstants.secondaryFontFamily,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    '${widget.subAmountPrefix}'
                    '${_formatAmount(widget.subAmount)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppConstants.secondaryFontFamily,
                      letterSpacing: 0.1,
                      color: AppColors.lightTextMuted,
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

  /// Formats [amount] using [TransactionCardWidget.amountFractionDigits].
  String _formatAmount(double amount) {
    final digits = widget.amountFractionDigits;
    return digits == null ? amount.toString() : amount.toStringAsFixed(digits);
  }
}
