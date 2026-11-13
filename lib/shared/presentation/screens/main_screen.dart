import 'package:inveio/shared/presentation/widgets/document_scanner_selector.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/presentation/widgets/bottom_nav_widget.dart';
import 'package:inveio/expenses/presentation/screens/expenses_screen.dart';
import 'package:inveio/home/presentation/screens/home_screen.dart';
import 'package:inveio/invoice/presentation/screens/invoice_screen.dart';
import 'package:inveio/profile/presentation/screens/profile_screen.dart';
import 'package:inveio/scan/presentation/cubit/receipt_scanner_cubit.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Notifies listeners of the current bottom navigation tab index.
final ValueNotifier<int> indexBottomNotifier = ValueNotifier(0);

/// Main scaffold holding the bottom navigation and page stack.
///
/// Displays [HomeScreen], [ExpensesScreen], [InvoiceScreen], and
/// [ProfileScreen] in an [IndexedStack].
class MainScreen extends StatefulWidget {
  /// Creates a [MainScreen] widget.
  const MainScreen({super.key});

  @override
  /// Creates the mutable state for [MainScreen].
  State<MainScreen> createState() => _MainScreenState();
}

/// Choices offered when a scan contains no usable amount.
enum _UnreadableScanAction { retake, manual }

/// Choices offered when a scan fails.
enum _ScanFailureAction { retry, manual }

class _MainScreenState extends State<MainScreen> {
  static final _pages = [
    const HomeScreen(),
    const ExpensesScreen(),
    const InvoiceScreen(),
    const ProfileScreen(),
  ];

  /// Guards the scan result so a single scan opens a form at most once.
  bool _scanResultHandled = false;

  /// Opens the document-type selector, or an empty form when [draft] is null.
  ///
  /// The sheet can be dismissed by tapping outside, dragging it down, the
  /// system back button, or its Cancel button. Any of those resets the scan
  /// guard so the next scan can be handled normally.
  Future<void> _showScannerSelector(
    ParsedReceipt? draft,
    String? imagePath,
  ) async {
    await showModalBottomSheet<void>(
      showDragHandle: false,
      isDismissible: true,
      context: context,
      builder: (sheetContext) {
        return DocumentScannerSelector(
          state: draft,
          imagePath: imagePath,
          onCancel: () => _scanResultHandled = false,
        );
      },
    );
    if (mounted) _scanResultHandled = false;
  }

  /// Explains that the scan yielded no amount and offers a next step.
  Future<void> _showUnreadableScanDialog() async {
    final action = await showDialog<_UnreadableScanAction>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Couldn't read this receipt"),
          content: const Text(
            'No amount was found on this document. Retake the scan or enter '
            'the details manually.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_UnreadableScanAction.retake),
              child: const Text('Retake'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_UnreadableScanAction.manual),
              child: const Text('Enter manually'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    switch (action) {
      case _UnreadableScanAction.retake:
        _scanResultHandled = false;
        await context.read<ReceiptScannerCubit>().scanReceipt();
      case _UnreadableScanAction.manual:
        await _showScannerSelector(null, null);
      case null:
        break;
    }
  }

  /// Shows a real scan error with Retry and manual-entry actions.
  Future<void> _showScanFailureDialog(String reason) async {
    final action = await showDialog<_ScanFailureAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Scan failed'),
          content: Text(reason),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ScanFailureAction.manual),
              child: const Text('Enter manually'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_ScanFailureAction.retry),
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    switch (action) {
      case _ScanFailureAction.retry:
        _scanResultHandled = false;
        await context.read<ReceiptScannerCubit>().scanReceipt();
      case _ScanFailureAction.manual:
        await _showScannerSelector(null, null);
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiptScannerCubit, ReceiptScannerState>(
      listener: (context, state) {
        if (_pages.length == 2) {
          context.read<ReceiptScannerCubit>().scanReceipt();
        }
        if (state is ReceiptScannerInitial) {
          _scanResultHandled = false;
          debugPrint('Scanner loading...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scanning receipt...'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is ScannerSuccess) {
          if (_scanResultHandled) return;
          _scanResultHandled = true;
          debugPrint('Scanner success: ${state.draft}');
          if (state.hasUsableAmount) {
            _showScannerSelector(state.draft, state.imagePath);
          } else {
            _showUnreadableScanDialog();
          }
        } else if (state is ScannerFailure) {
          _scanResultHandled = false;
          debugPrint('Scanner failure: ${state.reason}');
          _showScanFailureDialog(state.reason);
        }
      },
      child: Scaffold(
        extendBody: true,
        body: ValueListenableBuilder(
          valueListenable: indexBottomNotifier,
          builder: (context, value, child) {
            final pageIndex = value > 2 ? value - 1 : value;
            return IndexedStack(index: pageIndex, children: _pages);
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => context.read<ReceiptScannerCubit>().scanReceipt(),
          child: const Icon(LucideIcons.scanText),
        ),
        bottomNavigationBar: BottomNavWidget(
          bottomNavIndex: indexBottomNotifier,
        ),
      ),
    );
  }
}
