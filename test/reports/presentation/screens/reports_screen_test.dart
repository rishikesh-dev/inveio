import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inveio/reports/presentation/screens/reports_screen.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

TransactionEntity _expense({
  required String description,
  required double amount,
  required DateTime date,
  String? category,
}) =>
    TransactionEntity(
      uid: 'test-uid',
      type: TransactionType.expense,
      totalAmount: amount,
      taxableAmount: amount,
      gstSlab: 18,
      isInterState: false,
      cgst: 0,
      sgst: 0,
      igst: 0,
      description: description,
      category: category,
      date: date,
      createdAt: date,
      updatedAt: date,
    );

void main() {
  setUpAll(() {
    registerFallbackValue(const AllTransactionsRequested());
  });

  late MockTransactionBloc bloc;

  setUp(() {
    bloc = MockTransactionBloc();
  });

  tearDown(() {
    // Don't close MockBloc - it returns Null instead of Future<void>
  });

  TransactionState makeState({
    bool isLoadingLatest = false,
    List<TransactionEntity> latestExpenses = const [],
    String? latestError,
  }) {
    return TransactionState.initial().copyWith(
      latest: LatestTransactionsStatus(
        isLoadingLatest: isLoadingLatest,
        latestExpenses: latestExpenses,
        latestError: latestError,
      ),
    );
  }

  Widget buildScreen({required TransactionState reportState}) {
    when(() => bloc.state).thenReturn(reportState);
    when(() => bloc.stream).thenAnswer((_) => Stream.value(reportState));
    when(() => bloc.add(any())).thenAnswer((_) {});

    return MaterialApp(
      home: BlocProvider<TransactionBloc>.value(
        value: bloc,
        child: const ReportsScreen(),
      ),
    );
  }

  testWidgets('error state shows Retry button', (tester) async {
    final reportState = makeState(
      latestExpenses: const [],
      latestError: 'Network error',
    );

    await tester.pumpWidget(buildScreen(reportState: reportState));

    expect(find.text('Failed to load reports'), findsOneWidget);
    expect(find.text('Network error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('retry triggers AllTransactionsRequested', (tester) async {
    final reportState = makeState(
      latestExpenses: const [],
      latestError: 'Network error',
    );

    await tester.pumpWidget(buildScreen(reportState: reportState));

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => bloc.add(const AllTransactionsRequested())).called(2);
  });

  testWidgets('empty list shows empty state', (tester) async {
    final reportState = makeState(
      latestExpenses: const [],
    );

    await tester.pumpWidget(buildScreen(reportState: reportState));

    expect(find.text('No reports yet'), findsOneWidget);
    expect(find.text('Add an expense or invoice to see your insights.'),
        findsOneWidget);
  });

  testWidgets('single transaction shows cards without throwing', (tester) async {
    final now = DateTime(2026, 3, 12);
    final reportState = makeState(
      latestExpenses: [
        _expense(
          description: 'Office supplies',
          amount: 500,
          category: 'Supplies',
          date: now,
        ),
      ],
    );

    await tester.pumpWidget(buildScreen(reportState: reportState));

    expect(find.text('Monthly Spend'), findsOneWidget);
    expect(find.text('By Category'), findsOneWidget);
    expect(find.text('Cash Flow Summary'), findsOneWidget);
    expect(find.text('Supplies'), findsOneWidget);
  });

  testWidgets('loading state shows progress indicator', (tester) async {
    final reportState = makeState(
      isLoadingLatest: true,
      latestExpenses: const [],
    );

    await tester.pumpWidget(buildScreen(reportState: reportState));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
