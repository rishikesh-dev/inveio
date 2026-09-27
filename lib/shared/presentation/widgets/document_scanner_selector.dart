import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inveio/shared/routes/route_data/scan_result_route_data.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DocumentScannerSelector extends StatelessWidget {
  const DocumentScannerSelector({super.key, required this.state, this.imagePath});
  final ScannedReceiptEntity state;

  /// Local path of the scanned document image, forwarded to the form screens.
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 4,
            indent: MediaQuery.of(context).size.width * 0.4,
            endIndent: MediaQuery.of(context).size.width * 0.4,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.document_scanner,
                size: 35,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document scanned!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "We've detected text in your document.",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'What type of document is this?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          Text(
            'This helps us categorize it correctly.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: 13,
            ),
          ),
          Row(
            children: [
              DocumentScannerSelectorCard(
                title: 'Expense',
                subtitle: 'Bills, receipts, and other expense documents.',
                icon: LucideIcons.receipt,
                cardTheme: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    RouterConstants.addExpense,
                    extra: ScanResultRouteData(data: state, imagePath: imagePath),
                  );
                },
              ),
              DocumentScannerSelectorCard(
                title: 'Invoice',
                subtitle: 'Invoices from suppliers and vendors.',
                icon: LucideIcons.fileText,
                cardTheme: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  context.pushNamed(
                    RouterConstants.addInvoice,
                    extra: ScanResultRouteData(data: state, imagePath: imagePath),
                  );
                },
              ),
            ],
          ),
          Row(
            spacing: 5,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.shieldCheck,
                size: 14,
                color: Theme.of(context).hintColor,
              ),
              Text(
                'Your data is secure and private.',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DocumentScannerSelectorCard extends StatefulWidget {
  const DocumentScannerSelectorCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardTheme,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color cardTheme;
  final VoidCallback? onTap;

  @override
  State<DocumentScannerSelectorCard> createState() =>
      _DocumentScannerSelectorCardState();
}

class _DocumentScannerSelectorCardState
    extends State<DocumentScannerSelectorCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Material(
            color: widget.cardTheme.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              splashColor: widget.cardTheme.withAlpha(35),
              highlightColor: widget.cardTheme.withAlpha(15),
              onTap: widget.onTap,
              onHighlightChanged: (value) {
                setState(() => _isPressed = value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.cardTheme.withAlpha(50),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color.fromARGB(255, 53, 52, 52),
                      child: Icon(
                        widget.icon,
                        size: 30,
                        color: primary.withAlpha(200),
                      ),
                    ),
                    Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
