import 'package:flutter/material.dart';

class RadioSelectionWidget<T> extends StatelessWidget {
  final T value;
  final String label;
  final Color? bgColor;
  final EdgeInsets? padding, margin;
  final VoidCallback? onTap;

  const RadioSelectionWidget({
    super.key,
    required this.value,
    required this.label,
    this.bgColor,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                bgColor?.withValues(alpha: 0.3) ??
                Theme.of(context).dividerColor,
          ),
          color: bgColor?.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(color: bgColor?.withValues(alpha: 0.9)),
            ),
            Radio<T>(value: value),
          ],
        ),
      ),
    );
  }
}
