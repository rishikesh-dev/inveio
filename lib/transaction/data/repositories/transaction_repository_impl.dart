import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/transaction/data/models/transaction_model.dart';
import 'package:inveio/transaction/data/datasources/local/transaction_data_source.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:fpdart/fpdart.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDataSource _localDataSource;

  TransactionRepositoryImpl({required TransactionDataSource localDataSource})
    : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, TransactionEntity>> upsertTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      final saved = await _localDataSource.upsertTransaction(model);
      return right(saved.toEntity());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getLatestTransactions({
    TransactionType? type,
    int limit = 10,
  }) async {
    try {
      final models = await _localDataSource.getLatestTransactions(
        type: type,
        limit: limit,
      );
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getAllTransactions() async {
    try {
      final models = await _localDataSource.getAllTransactions();
      return right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int localId) async {
    try {
      await _localDataSource.deleteTransaction(localId);
      return right(null);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }
}
