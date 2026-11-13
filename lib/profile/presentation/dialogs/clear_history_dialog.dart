import 'package:flutter/material.dart';
import 'package:inveio/profile/presentation/widgets/text_field_widget.dart';

class ClearHistoryDialog extends StatefulWidget {
  const ClearHistoryDialog({super.key});

  @override
  State<ClearHistoryDialog> createState() => _ClearHistoryDialogState();
}

class _ClearHistoryDialogState extends State<ClearHistoryDialog> {
  final TextEditingController _controller = TextEditingController();
  bool get _isConfirmed => _controller.text == 'DELETE';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm deletion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes all your expenses and invoices.',
          ),
          const SizedBox(height: 16),
          ClearHistoryTextFieldWidget(controller: _controller),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isConfirmed
              ? () => Navigator.of(context).pop(_controller.text)
              : null,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
