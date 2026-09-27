import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Horizontal scrollable row of expense category chips.
class ExpenseCategoryRow extends StatelessWidget {
  const ExpenseCategoryRow({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  /// The currently selected category, or null.
  final String? selectedCategory;

  /// Callback invoked when a category is selected.
  final ValueChanged<String> onCategorySelected;

  static const _categories = [
    'Supplies',
    'Travel',
    'Software',
    'Rent',
    'Utilities',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _categories.map((cat) {
          final selected = selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onCategorySelected(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryAlpha : AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.darkBorder,
                  ),
                ),
                child: Text(
                  cat,
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
          );
        }).toList(),
      ),
    );
  }
}
