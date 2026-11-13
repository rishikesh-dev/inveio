import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

TransactionEntity _invoice({required String description}) => TransactionEntity(
  uid: 'test-uid',
  type: TransactionType.invoice,
  totalAmount: 1180,
  taxableAmount: 1000,
  gstSlab: 18,
  isInterState: false,
  cgst: 90,
  sgst: 90,
  igst: 0,
  description: description,
  date: DateTime(2024, 1, 15),
  createdAt: DateTime(2024, 1, 15),
  updatedAt: DateTime(2024, 1, 15),
);

void main() {
  late MockTransactionRepository repository;

  setUp(() {
    repository = MockTransactionRepository();
  });

  TransactionBloc buildBloc() => TransactionBloc(
    transactionRepository: repository,
    uid: 'test-uid',
  );

  group('ClearHistory', () {
    blocTest<TransactionBloc, TransactionState>(
      'does not clear history unless confirmation is exactly DELETE',
      build: () {
        when(
          () => repository.clearHistory(),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => repository.getAllTransactions(),
        ).thenAnswer((_) async => right(<TransactionEntity>[]));
        when(
          () => repository.getAllTransactions(type: TransactionType.invoice),
        ).thenAnswer((_) async => right(<TransactionEntity>[]));
        return buildBloc();
      },
      act: (bloc) {
        bloc.add(const ClearHistory(confirmation: 'delete'));
        bloc.add(const ClearHistory(confirmation: 'DELETE '));
        bloc.add(const ClearHistory(confirmation: 'DELETE'));
      },
      wait: const Duration(milliseconds: 10),
      verify: (_) {
        verify(() => repository.clearHistory()).called(1);
      },
    );
  });

  group('AllInvoicesRequested', () {
    final invoices = [
      _invoice(description: 'Invoice A'),
      _invoice(description: 'Invoice B'),
    ];

    blocTest<TransactionBloc, TransactionState>(
      'fills invoices and leaves latestExpenses unchanged',
      build: () {
        when(
          () => repository.getAllTransactions(type: TransactionType.invoice),
        ).thenAnswer((_) async => right(invoices));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AllInvoicesRequested()),
      expect: () => [
        isA<TransactionState>().having(
          (state) => state.invoices.isLoadingInvoices,
          'isLoadingInvoices',
          true,
        ),
        isA<TransactionState>()
            .having((state) => state.invoices.invoices, 'invoices', invoices)
            .having(
              (state) => state.invoices.isLoadingInvoices,
              'isLoadingInvoices',
              false,
            )
            .having(
              (state) => state.latest.latestExpenses,
              'latestExpenses',
              isEmpty,
            ),
      ],
    );
  });
}
