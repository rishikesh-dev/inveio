import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A themed button for third-party or alternative authentication methods.
class AuthButton extends StatelessWidget {
  /// Creates an [AuthButton] with the given [icon], [label], and [onPressed] callback.
  const AuthButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  });
  /// The icon widget displayed on the button.
  final Widget icon;
  /// The text label displayed on the button.
  final String label;
  /// The callback invoked when the button is pressed.
  final VoidCallback? onPressed;

  /// Builds the button widget with an outlined style and centered icon-label layout.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: AppColors.darkTextPrimary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
