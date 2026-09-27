import 'package:inveio/shared/constants/state_code.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable GSTIN input field with built-in validation and formatting.
///
/// Use anywhere a GSTIN is collected (onboarding, edit profile, expenses,
/// invoices) without re-creating validators or input formatters.
class GstinTextField extends StatelessWidget {
  /// Creates a [GstinTextField].
  const GstinTextField({
    super.key,
    required this.controller,
    this.hintText = 'GSTIN',
    this.textFieldLabel,
    this.onChanged,
    this.validator,
    this.enabled,
    this.focusNode,
    this.textInputAction,
    this.prefix,
    this.suffix,
    this.showStateDetection = false,
  });

  final TextEditingController controller;
  final String hintText;
  final String? textFieldLabel;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool? enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Widget? prefix;
  final Widget? suffix;

  /// Shows a "state detected" row beneath the field based on the first two
  /// digits of the GSTIN (see [stateCodes]).
  final bool showStateDetection;

  /// Standard GSTIN length.
  static const int gstinLength = 15;

  /// Validates a GSTIN format: `[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]`.
  static final RegExp gstinPattern = RegExp(
    r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z][1-9A-Z]Z[0-9A-Z]$',
  );

  /// Validator for an optional GSTIN field: empty is allowed, otherwise
  /// the format must match.
  static String? optionalValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    return formatValidator(text);
  }

  /// Validator for a required GSTIN field: empty fails, format must match.
  static String? requiredValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Please enter your GSTIN';
    return formatValidator(text);
  }

  /// Shared format check for non-empty values.
  static String? formatValidator(String text) {
    if (text.length != gstinLength) {
      return 'GSTIN must be $gstinLength characters';
    }
    if (!gstinPattern.hasMatch(text)) {
      return 'Enter a valid GSTIN';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final field = TextFieldWidget(
      controller: controller,
      hintText: hintText,
      textFieldLabel: textFieldLabel,
      onChanged: onChanged,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      prefix: prefix,
      suffix: suffix,
      validator: validator ?? optionalValidator,
      textCapitalization: TextCapitalization.characters,
      maxLength: gstinLength,
      counterText: '',
      inputFormatters: [
        LengthLimitingTextInputFormatter(gstinLength),
        FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z]')),
        _UpperCaseTextInputFormatter(),
      ],
    );

    if (!showStateDetection) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        field,
        const SizedBox(height: 8),
        _StateDetectionRow(controller: controller),
      ],
    );
  }
}

class _StateDetectionRow extends StatelessWidget {
  const _StateDetectionRow({required this.controller});

  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final text = controller.text.trim();
        final code = text.length >= 2 ? text.substring(0, 2) : null;
        final hasCode = code != null && stateCodes.containsKey(code);
        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasCode
                    ? const Color(0xFF00D97E)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              hasCode
                  ? 'State detected: ${stateCodes[code]!} ($code)'
                  : 'State will be detected',
              style: TextStyle(
                fontSize: 13,
                color: hasCode ? const Color(0xFF00D97E) : Colors.white38,
                fontWeight: hasCode ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UpperCaseTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
