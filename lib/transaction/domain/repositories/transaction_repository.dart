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

  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions();

  Future<Either<Failure, void>> deleteTransaction(int localId);
}
