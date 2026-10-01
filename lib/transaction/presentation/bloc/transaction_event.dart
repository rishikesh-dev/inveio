part of 'transaction_bloc.dart';

/// Base class for events handled by [TransactionBloc].
@immutable
sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Requests the latest transactions (used to refresh list screens).
final class LatestTransactionsRequested extends TransactionEvent {
  /// Maximum number of transactions to fetch.
  final int limit;

  const LatestTransactionsRequested({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

/// Requests every transaction.
final class AllTransactionsRequested extends TransactionEvent {
  const AllTransactionsRequested();
}

/// Requests details for a single transaction by its id.
final class TransactionDetailsRequested extends TransactionEvent {
  /// The server id or local id (as a string) of the transaction.
  final String expenseId;

  const TransactionDetailsRequested(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

/// Deletes a transaction by its local Isar id.
final class DeleteTransaction extends TransactionEvent {
  /// The local Isar id of the transaction to delete.
  final int localId;

  const DeleteTransaction(this.localId);

  @override
  List<Object?> get props => [localId];
}
