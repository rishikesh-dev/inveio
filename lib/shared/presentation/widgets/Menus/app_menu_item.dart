import 'package:flutter/material.dart';

class AppMenuItem<T> {
  final T value;
  final String label;
  final IconData icon;
  final bool isDestructive;
  final bool showDividerBefore;
  final VoidCallback? onTap;

  const AppMenuItem({
    required this.value,
    required this.label,
    required this.icon,
    this.isDestructive = false,
    this.showDividerBefore = false,
    this.onTap,
  });
}

class AppContextMenu {
  static Future<T?> show<T>({
    required BuildContext context,
    required Offset position,
    required List<AppMenuItem<T>> items,
    Color? backgroundColor,
  }) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    return showMenu<T>(
      context: context,
      clipBehavior: Clip.antiAlias,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      color: backgroundColor ?? const Color(0xFF191D19),
      elevation: 2,
      menuPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF343A34)),
      ),
      items: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        final color = item.isDestructive
            ? const Color(0xFFFF6464)
            : const Color(0xFFF2F2ED);

        return PopupMenuItem<T>(
          onTap: item.onTap,
          value: item.value,
          height: 48,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: index == 0 ? 20 : 5,
            bottom: 10,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: color),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
