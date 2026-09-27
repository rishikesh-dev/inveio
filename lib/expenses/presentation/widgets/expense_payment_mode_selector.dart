import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Row of selectable payment mode buttons (Cash, Bank, UPI, Card).
class ExpensePaymentModeSelector extends StatelessWidget {
  const ExpensePaymentModeSelector({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
  });

  /// The currently selected payment mode.
  final PaymentMode? selectedMode;

  /// Callback invoked when a payment mode is selected.
  final ValueChanged<PaymentMode> onModeSelected;

  static const _labels = {
    PaymentMode.cash: 'Cash',
    PaymentMode.bank: 'Bank',
    PaymentMode.upi: 'UPI',
    PaymentMode.card: 'Card',
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PaymentMode.values.map((mode) {
        final selected = selectedMode == mode;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: mode == PaymentMode.cash ? 0 : 4,
              right: mode == PaymentMode.card ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => onModeSelected(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryAlpha : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.darkBorder,
                  ),
                ),
                child: Text(
                  _labels[mode]!,
                  style: TextStyle(
                    color: selected
                        ? AppColors.primary
                        : AppColors.darkTextSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Switch toggle for ITC (Input Tax Credit) eligibility.
class ExpenseItcToggle extends StatelessWidget {
  const ExpenseItcToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  /// Whether ITC is eligible.
  final bool value;

  /// Callback invoked when the toggle value changes.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'ITC Eligible',
        style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 15),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primaryAlpha,
    );
  }
}
