part of 'transaction_bloc.dart';

/// Base class for events handled by [TransactionBloc].

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

/// Requests every invoice.
final class AllInvoicesRequested extends TransactionEvent {
  const AllInvoicesRequested();
}

/// Requests details for a single transaction by its local Isar id.
final class TransactionDetailsRequested extends TransactionEvent {
  /// The local Isar id of the transaction.
  final int localId;

  const TransactionDetailsRequested(this.localId);

  @override
  List<Object?> get props => [localId];
}

/// Deletes a transaction by its local Isar id.
final class DeleteTransaction extends TransactionEvent {
  /// The local Isar id of the transaction to delete.
  final int localId;

  const DeleteTransaction(this.localId);

  @override
  List<Object?> get props => [localId];
}

/// Clears all expense and invoice history.
final class ClearHistory extends TransactionEvent {
  /// Text the user typed to confirm the destructive action.
  final String confirmation;

  const ClearHistory({this.confirmation = ''});

  @override
  List<Object?> get props => [confirmation];
}
