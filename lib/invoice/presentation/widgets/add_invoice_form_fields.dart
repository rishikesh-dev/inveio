import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Label widget used for invoice form fields.
class InvoiceFieldLabel extends StatelessWidget {
  const InvoiceFieldLabel(this.label, {super.key});

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

/// Displays the invoice date and opens a date picker on tap.
class InvoiceDateField extends StatelessWidget {
  const InvoiceDateField({super.key, required this.date, required this.onTap});

  /// The currently selected date.
  final DateTime? date;

  /// Callback when the date field is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

/// Displays the due date and opens a date picker on tap.
class InvoiceDueDateField extends StatelessWidget {
  const InvoiceDueDateField({
    super.key,
    required this.dueDate,
    required this.onTap,
  });

  /// The currently selected due date, or null.
  final DateTime? dueDate;

  /// Callback when the due date field is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              dueDate != null
                  ? DateFormat('MMM dd, yyyy').format(dueDate!)
                  : 'Select due date',
              style: TextStyle(
                color: dueDate != null
                    ? AppColors.darkTextPrimary
                    : AppColors.darkTextMuted,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
