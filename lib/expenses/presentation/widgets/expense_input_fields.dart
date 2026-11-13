import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Label widget used for expense form fields.
class ExpenseFieldLabel extends StatelessWidget {
  const ExpenseFieldLabel(this.label, {super.key});

  /// The label text to display.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

/// Displays the selected date and opens a date picker on tap.
class ExpenseDateField extends StatelessWidget {
  const ExpenseDateField({
    super.key,
    required this.date,
    this.time,
    required this.onTap,
    required this.timePicker,
  });

  /// The currently selected date.
  final DateTime? date;

  /// The currently selected time.
  final TimeOfDay? time;

  /// Callback when the date field is tapped.
  final VoidCallback onTap;

  /// Callback when the time field is tapped.
  final VoidCallback timePicker;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.darkInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date!)
                        : 'Select date',
                    style: TextStyle(
                      color: date != null
                          ? AppColors.darkTextPrimary
                          : AppColors.darkTextMuted,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: 150,
          child: GestureDetector(
            onTap: timePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.darkInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.clock,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    time != null
                        ? time!.format(context)
                        : date != null
                        ? DateFormat('hh:mm a').format(date!)
                        : '--:--',
                    style: const TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shared input decoration for expense form text fields.
InputDecoration expenseInputDecoration({required String hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 15),
    filled: true,
    fillColor: AppColors.darkInput,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.darkBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    counterText: '',
  );
}
