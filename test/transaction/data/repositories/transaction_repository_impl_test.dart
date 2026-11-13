import 'package:flutter_test/flutter_test.dart';
import 'package:inveio/transaction/data/datasources/local/transaction_data_source.dart';
import 'package:inveio/transaction/data/models/transaction_model.dart';
import 'package:inveio/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionDataSource extends Mock implements TransactionDataSource {}

TransactionModel _transaction({
  required TransactionType type,
  required String description,
}) => TransactionModel.fromEntity(
  TransactionEntity(
    uid: 'uid',
    type: type,
    totalAmount: 100,
    taxableAmount: 100,
    gstSlab: 18,
    isInterState: false,
    cgst: 9,
    sgst: 9,
    igst: 0,
    description: description,
    date: DateTime(2024, 1, 15),
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  ),
);

void main() {
  late MockTransactionDataSource localDataSource;

  setUp(() {
    localDataSource = MockTransactionDataSource();
  });

  group('getAllTransactions', () {
    test('returns only invoices from a mixed list when type is invoice', () async {
      when(() => localDataSource.getAllTransactions()).thenAnswer(
        (_) async => [
          _transaction(
            type: TransactionType.expense,
            description: 'Office supplies',
          ),
          _transaction(
            type: TransactionType.invoice,
            description: 'Client invoice',
          ),
        ],
      );
      final repository = TransactionRepositoryImpl(
        localDataSource: localDataSource,
      );

      final result = await repository.getAllTransactions(
        type: TransactionType.invoice,
      );

      final transactions = result.match(
        (failure) => fail('Expected Right, got Left: $failure'),
        (transactions) => transactions,
      );
      expect(transactions, hasLength(1));
      expect(transactions.single.type, TransactionType.invoice);
      expect(transactions.single.description, 'Client invoice');
    });
  });
}
