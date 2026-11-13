import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Custom bottom navigation bar with five tabs (Home, Expenses, Scan, Invoice, Profile).
class BottomNavWidget extends StatelessWidget {
  /// Notifier that tracks the currently selected tab index.
  final ValueNotifier<int> bottomNavIndex;

  /// Creates a [BottomNavWidget] bound to the given [bottomNavIndex] notifier.
  const BottomNavWidget({super.key, required this.bottomNavIndex});

  @override
  /// Builds the bottom navigation bar with five tabs and a center FAB placeholder.
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: bottomNavIndex,
      builder: (context, value, child) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: value,
          onTap: (value) {
            if (value == 2) return;
            bottomNavIndex.value = value;
          },
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          enableFeedback: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(LucideIcons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(LucideIcons.dollarSign),
              ),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(icon: SizedBox(), label: ''),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(LucideIcons.receipt),
              ),
              label: 'invoice',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Icon(LucideIcons.user),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
