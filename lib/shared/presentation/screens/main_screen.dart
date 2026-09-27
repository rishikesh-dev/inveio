import 'package:inveio/shared/presentation/widgets/document_scanner_selector.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/presentation/widgets/bottom_nav_widget.dart';
import 'package:inveio/expenses/presentation/screens/expenses_screen.dart';
import 'package:inveio/home/presentation/screens/home_screen.dart';
import 'package:inveio/invoice/presentation/screens/invoice_screen.dart';
import 'package:inveio/profile/presentation/screens/profile_screen.dart';
import 'package:inveio/scan/presentation/cubit/receipt_scanner_cubit.dart';
import 'package:inveio/scan/presentation/screens/scan_receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Notifies listeners of the current bottom navigation tab index.
final ValueNotifier<int> indexBottomNotifier = ValueNotifier(0);

/// Main scaffold holding the bottom navigation and page stack.
///
/// Displays [HomeScreen], [ExpensesScreen], [ScanReceiptScreen],
/// [InvoiceScreen], and [ProfileScreen] in an [IndexedStack].
class MainScreen extends StatefulWidget {
  /// Creates a [MainScreen] widget.
  const MainScreen({super.key});

  @override
  /// Creates the mutable state for [MainScreen].
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static final _pages = [
    const HomeScreen(),
    const ExpensesScreen(),
    const SizedBox(),
    const InvoiceScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReceiptScannerCubit, ReceiptScannerState>(
      listener: (context, state) {
        if (state is ReceiptScannerInitial) {
          debugPrint('Scanner loading...');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scanning receipt...'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        if (state is ScannerSuccess) {
          debugPrint('Scanner success: ${state.draft}');
          showModalBottomSheet(
            showDragHandle: false,
            isDismissible: false,
            context: context,
            builder: (sheetContext) {
              return DocumentScannerSelector(
                state: state.draft,
                imagePath: state.imagePath,
              );
            },
          );
        }
        if (state is ScannerFailure) {
          debugPrint('Scanner failure: ${state.reason}');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.reason)));
        }
      },
      child: Scaffold(
        extendBody: true,
        body: ValueListenableBuilder(
          valueListenable: indexBottomNotifier,
          builder: (context, value, child) {
            return IndexedStack(index: value, children: _pages);
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
