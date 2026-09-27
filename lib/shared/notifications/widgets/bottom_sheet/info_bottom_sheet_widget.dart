import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InfoBottomSheetWidget extends StatelessWidget {
  const InfoBottomSheetWidget({
    super.key,
    this.icon,
    required this.title,
    required this.content,
    this.buttonLabel,
    this.onPressed,
    this.iconAlignment,
    this.padding,
    this.bottomSheetCrossAlignment,
    this.titleTextAlign,
    this.contentTextAlign,
    this.buttonColor,
  });
  final String title, content;
  final String? buttonLabel;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AlignmentGeometry? iconAlignment;
  final EdgeInsets? padding;
  final CrossAxisAlignment? bottomSheetCrossAlignment;
  final TextAlign? titleTextAlign, contentTextAlign;
  final Color? buttonColor;
  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
      child: Column(
        crossAxisAlignment:
            bottomSheetCrossAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton.outlined(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(LucideIcons.xCircle),
            ),
          ),
          const SizedBox(height: 30.0),
          Align(
            alignment: iconAlignment ?? Alignment.center,
            child: icon ?? const SizedBox.shrink(),
          ),
          Text(
            title,
            textAlign: titleTextAlign,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: contentTextAlign ?? TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 40.0),
          buttonLabel != null
              ? NeonButton(
                  label: buttonLabel ?? '',
                  onPressed: onPressed,
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(25),
                )
              : const SizedBox(),
          const SizedBox(height: 30.0),
        ],
      ),
    );
  }
}
