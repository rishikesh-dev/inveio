import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/data/models/transaction_model.dart';
import 'package:inveio/transaction/data/datasources/local/transaction_data_source.dart';
import 'package:isar_community/isar.dart';

class IsarTransactionDataSourceImpl implements TransactionDataSource {
  final Isar _isar;

  IsarTransactionDataSourceImpl({required Isar isar}) : _isar = isar;

  @override
  Future<TransactionModel> upsertTransaction(
    TransactionModel transaction,
  ) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.put(transaction);
    });
    return transaction;
  }

  @override
  Future<List<TransactionModel>> getLatestTransactions({
    TransactionType? type,
    int limit = 10,
  }) async {
    final transactions = await _isar.transactionModels.where().findAll();
    final filtered = type != null
        ? transactions.where((t) => t.type == type).toList()
        : transactions;
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered.take(limit).toList();
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return _isar.transactionModels.where().findAll();
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    return _isar.transactionModels.where().idEqualTo(id).findFirst();
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _isar.writeTxn(() async {
      await _isar.transactionModels.delete(id);
    });
  }
}
