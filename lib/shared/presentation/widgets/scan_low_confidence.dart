import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Applies a low-confidence warning (amber icon + helper text) to a field
/// decoration, mirroring the expense form's scan-verify hint.
///
/// Set [lowConfidenceText] to false to show only the suffix icon; the caller
/// is then responsible for rendering the separate hint line beneath the field.
InputDecoration applyScanLowConfidence(
  InputDecoration base, {
  required bool lowConfidence,
  bool lowConfidenceText = true,
}) {
  if (!lowConfidence) return base;
  return base.copyWith(
    suffixIcon: const Icon(
      Icons.warning_amber_outlined,
      color: AppColors.warning,
    ),
    helperText: lowConfidenceText ? 'Please verify this value' : null,
    helperStyle: const TextStyle(color: AppColors.warning, fontSize: 12),
  );
}

/// Inline hint shown beneath a low-confidence scanned field.
///
/// Returns an empty [SizedBox] when the field is confident so callers can
/// unconditionally place it in a column without branching.
Widget scanLowConfidenceHint({required bool lowConfidence}) {
  if (!lowConfidence) return const SizedBox.shrink();
  return Text(
    'Please verify this value',
    style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
  );
}
