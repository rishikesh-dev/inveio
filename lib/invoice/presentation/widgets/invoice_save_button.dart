import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:flutter/material.dart';

/// Neon-styled save button for the invoice form.
class InvoiceSaveButton extends StatelessWidget {
  const InvoiceSaveButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  /// Whether the save operation is in progress.
  final bool isSaving;
  /// Callback when the save button is pressed.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return NeonButton(
      label: 'Save invoice',
      onPressed: isSaving ? null : onPressed,
    );
  }
}
