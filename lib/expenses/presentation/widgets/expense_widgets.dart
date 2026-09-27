import 'package:inveio/shared/presentation/widgets/app_card.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/expenses/presentation/screens/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// An icon button that opens the expense filter bottom sheet.
class ExpenseFilterButton extends StatelessWidget {
  const ExpenseFilterButton({super.key, required this.onTap});

  /// Callback invoked when the filter button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.darkCardAlt,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.darkBorderSoft),
        ),
        child: const Icon(
          LucideIcons.slidersHorizontal,
          color: AppColors.darkTextSecondary,
          size: 22,
        ),
      ),
    );
  }
}

/// A search input field for filtering expense transactions.
class ExpenseSearchBox extends StatelessWidget {
  const ExpenseSearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.darkCardAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorderSoft),
      ),
      child: const Row(
        children: [
          Icon(
            LucideIcons.search,
            color: AppColors.darkTextSecondary,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextFieldWidget(
              hintText: 'Search transactions...',
              textStyle: TextStyle(color: AppColors.darkTextPrimary),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A grouped section of expense items with a title header.
class ExpenseGroup extends StatelessWidget {
  const ExpenseGroup({super.key, required this.section});

  /// The section data containing the title and list of expense items.
  final ExpenseSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            section.title,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: EdgeInsets.zero,
          radius: 14,
          color: AppColors.darkCardAlt,
          borderColor: AppColors.darkBorderSoft,
          child: Column(
            children: [
              for (var i = 0; i < section.items.length; i++)
                ExpenseTile(
                  item: section.items[i],
                  showDivider: i != section.items.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A tappable row displaying an expense item's icon, title, meta, amount,
/// and an optional GST badge.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.item, required this.showDivider});

  /// The expense item data to display.
  final ExpenseItem item;

  /// Whether to show a divider below this tile.
  final bool showDivider;

  /// Navigates to the transaction details screen with a fade transition.
  void openDetails(BuildContext context) {
    final expenseId = item.id;
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: TransactionDetailsScreen(expenseId: expenseId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openDetails(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF303729),
                  child: Icon(
                    item.icon,
                    color: AppColors.darkTextSecondary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.meta,
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
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          item.amount,
                          maxLines: 1,
                          style: const TextStyle(
                            color: AppColors.darkTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (item.hasGst) const GstPill(),
                    ],
                  ),
                ),
              ],
            ),
            if (showDivider)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Divider(color: AppColors.darkBorderSoft),
              ),
          ],
        ),
      ),
    );
  }
}

/// A small green pill-shaped badge indicating the expense includes GST.
class GstPill extends StatelessWidget {
  const GstPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF26370C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF587600)),
      ),
      child: const Text(
        'GST',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Data model for a grouped section of expense items under a title.
class ExpenseSection {
  const ExpenseSection({required this.title, required this.items});

  /// The section heading label (e.g. "TODAY").
  final String title;

  /// The list of expense items in this section.
  final List<ExpenseItem> items;
}

/// Data model for a single expense entry.
class ExpenseItem {
  const ExpenseItem({
    required this.title,
    required this.meta,
    required this.amount,
    required this.icon,
    this.hasGst = false,
    required this.id,
  });

  /// The merchant or transaction name.
  final String title;

  /// Additional metadata like time and category.
  final String meta;

  /// The formatted monetary amount string.
  final String amount;

  /// The icon representing the transaction category.
  final IconData icon;

  /// Whether this expense includes a GST component.
  final bool hasGst;
  final String id;
}
