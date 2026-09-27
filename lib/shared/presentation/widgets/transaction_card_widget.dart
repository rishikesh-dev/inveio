import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A card widget that displays a transaction summary with title, subtitle, and amounts.
class TransactionCardWidget extends StatefulWidget {
  /// Creates a [TransactionCardWidget] with the given transaction details.
  const TransactionCardWidget({
    super.key,
    this.onTap,
    required this.title,
    required this.subTitle,
    required this.mainAmount,
    required this.subAmount,
    this.icon,
  });
  /// Callback when the card is tapped.
  final VoidCallback? onTap;
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

  @override
  /// Creates the mutable state for [TransactionCardWidget].
  State<TransactionCardWidget> createState() => _TransactionCardWidgetState();
}

class _TransactionCardWidgetState extends State<TransactionCardWidget> {
  bool _pressed = false;

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
        onLongPress: () {},
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
                child: Icon(widget.icon, size: 20.0, color: Colors.green),
              ),
              const SizedBox(width: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppConstants.secondaryFontFamily,
                      letterSpacing: 0.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    widget.subTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppConstants.secondaryFontFamily,
                      letterSpacing: 0.1,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.mainAmount.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: AppConstants.secondaryFontFamily,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    widget.subAmount.toString(),
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
}
