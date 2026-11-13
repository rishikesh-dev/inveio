import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract class TransactionRepository {
  Future<Either<Failure, TransactionEntity>> upsertTransaction(
    TransactionEntity transaction,
  );

  Future<Either<Failure, List<TransactionEntity>>> getLatestTransactions({
    TransactionType? type,
    int limit = 10,
  });

  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions({
    TransactionType? type,
  });

  /// Looks up a single transaction by its local Isar ID.
  ///
  /// Returns `right(null)` when no transaction exists for [localId].
  Future<Either<Failure, TransactionEntity?>> getTransactionByLocalId(
    int localId,
  );

  Future<Either<Failure, void>> deleteTransaction(int localId);

  /// Deletes every expense and invoice record. Other app data is untouched.
  Future<Either<Failure, void>> clearHistory();
}
