import 'package:flutter/material.dart';

/// A styled uppercase section label used as a heading above settings groups.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  /// The text to display as the section heading.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).hintColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
