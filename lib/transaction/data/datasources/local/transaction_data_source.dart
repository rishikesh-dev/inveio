import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/data/models/transaction_model.dart';

abstract class TransactionDataSource {
  Future<TransactionModel> upsertTransaction(TransactionModel transaction);

  Future<List<TransactionModel>> getLatestTransactions({
    TransactionType? type,
    int limit = 10,
  });

  Future<List<TransactionModel>> getAllTransactions();

  Future<TransactionModel?> getTransactionById(String id);

  Future<void> deleteTransaction(int id);
}
