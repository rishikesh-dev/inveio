import 'package:flutter/material.dart';

/// A tappable row option used for selecting an item in the onboarding flow.
class OnboardingRowOption extends StatelessWidget {
  /// The display text for this option.
  final String label;

  /// Whether this option is currently selected.
  final bool isSelected;

  /// The callback invoked when the option is tapped.
  final VoidCallback onTap;

  /// Creates an [OnboardingRowOption] with the given [label], [isSelected], and [onTap].
  const OnboardingRowOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.75),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            Text(
              isSelected ? '\u2713' : '+',
              style: TextStyle(
                fontSize: isSelected ? 16 : 18,
                color: isSelected
                    ? const Color(0xFF00D97E)
                    : Colors.white.withValues(alpha: 0.25),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
