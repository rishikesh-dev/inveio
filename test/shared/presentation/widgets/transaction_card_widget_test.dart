import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inveio/shared/presentation/widgets/transaction_card_widget.dart';

void main() {
  testWidgets('invoice card shows Share PDF and Print menu items',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionCardWidget(
            transactionUid: 'uid-1',
            transactionLocalId: 1,
            title: 'Invoice #001',
            subTitle: 'Mar 12, 2026',
            mainAmount: 118.0,
            subAmount: 18.0,
            icon: Icons.description,
            iconColor: Colors.blue,
            invoiceActions: true,
            onMenuAction: (action) {},
          ),
        ),
      ),
    );

    // Long press to open the context menu
    final card = find.byType(TransactionCardWidget);
    await tester.longPress(card);
    await tester.pumpAndSettle();

    expect(find.text('Share PDF'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
  });

  testWidgets('expense card does not show Share PDF and Print menu items',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TransactionCardWidget(
            transactionUid: 'uid-1',
            transactionLocalId: 1,
            title: 'Office supplies',
            subTitle: 'Mar 12, 2026 - Expense',
            mainAmount: 50.0,
            subAmount: 9.0,
            icon: Icons.currency_rupee_sharp,
            // invoiceActions defaults to false
            onMenuAction: (action) {},
          ),
        ),
      ),
    );

    // Long press to open the context menu
    final card = find.byType(TransactionCardWidget);
    await tester.longPress(card);
    await tester.pumpAndSettle();

    expect(find.text('Share PDF'), findsNothing);
    expect(find.text('Print'), findsNothing);
    // Expense card still shows Share, Edit, View details, Delete
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
  });
}
