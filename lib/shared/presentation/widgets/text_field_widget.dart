import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/theme/app_text_styles.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.suffix,
    this.prefix,
    this.obscureText,
    this.onChanged,
    this.verticalMargin,
    this.horizontalMargin,
    this.contentPaddingVertical,
    this.contentPaddingHorizontal,
    this.validator,
    this.errorText,
    this.showBorder = true,
    this.decoration,
    this.hintFontSize,
    this.keyboardType,
    this.textStyle,
    this.cursorColor,
    this.maxLength,
    this.textCapitalization,
    this.textAlign,
    this.inputFormatters,
    this.textInputAction,
    this.maxLines,
    this.expands,
    this.onFieldSubmitted,
    this.readOnly,
    this.enabled,
    this.textFieldLabel,
    this.labelStyle,
    this.focusNode,
    this.counterText,
    this.showHelperSpace,
  });

  final String hintText;
  final String? errorText, textFieldLabel;
  final double? verticalMargin;
  final double? horizontalMargin;
  final double? contentPaddingVertical;
  final double? contentPaddingHorizontal;
  final double? hintFontSize;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final InputDecoration? decoration;
  final Widget? suffix;
  final Widget? prefix;
  final bool? obscureText;
  final bool? showBorder;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final Color? cursorColor;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final TextAlign? textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final bool? expands, readOnly, enabled;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  // Pass '' to hide the built-in maxLength counter, null to use default counter.
  final String? counterText;
  // Whether to reserve helper text space when there's no helper/error. Defaults to false.
  final bool? showHelperSpace;

  @override
  Widget build(BuildContext context) {
    final border = showBorder == true
        ? Theme.of(context).inputDecorationTheme.border
        : InputBorder.none;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalMargin ?? 0.0,
        horizontal: horizontalMargin ?? 0.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (textFieldLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              textFieldLabel!,
              style:
                  labelStyle ??
                  AppTextStyles.labelMedium.copyWith(
                    color: AppColors.darkTextSecondary,
                  ),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            enabled: enabled,
            readOnly: readOnly ?? false,
            validator: validator,
            keyboardType: keyboardType,
            style:
                textStyle ??
                AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkTextPrimary,
                ),
            controller: controller,
            onChanged: onChanged,
            obscureText: obscureText ?? false,
            cursorColor: cursorColor ?? AppColors.primary,
            maxLength: maxLength,
            focusNode: focusNode,
            textCapitalization: textCapitalization ?? TextCapitalization.none,
            textAlign: textAlign ?? TextAlign.start,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            maxLines: maxLines ?? 1,
            expands: expands ?? false,
            onFieldSubmitted: onFieldSubmitted,
            decoration:
                decoration ??
                InputDecoration(
                  errorText: errorText,
                  helperText: showHelperSpace == true ? '' : null,
                  counterText: counterText,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: contentPaddingVertical ?? 16,
                    horizontal: contentPaddingHorizontal ?? 16,
                  ),
                  prefixIcon: prefix != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 16, right: 12),
                          child: IconTheme(
                            data: const IconThemeData(
                              color: AppColors.darkTextMuted,
                              size: 20,
                            ),
                            child: prefix!,
                          ),
                        )
                      : null,
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: suffix,
                  hintText: hintText,
                  hintStyle:
                      (hintFontSize != null
                              ? AppTextStyles.bodyMedium.copyWith(
                                  fontSize: hintFontSize,
                                )
                              : AppTextStyles.bodyMedium)
                          .copyWith(color: AppColors.darkTextMuted),
                  border: border,
                  enabledBorder: border,
                  focusedBorder: border,
                  errorBorder: border,
                  focusedErrorBorder: border,
                  disabledBorder: border,
                ),
          ),
        ],
      ),
    );
  }
}
