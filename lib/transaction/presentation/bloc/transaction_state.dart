part of 'transaction_bloc.dart';

const _sentinel = Object();

/// State for [TransactionBloc]: the latest/all transaction list status and the
/// transaction currently selected for the details screen.
@immutable
sealed class TransactionState with Equatable {
  /// The latest/all transactions list status.
  LatestTransactionsStatus get latest;

  /// The transaction selected for the details screen, if any.
  TransactionEntity? get selectedTransaction;

  const TransactionState();

  /// The initial, empty state.
  factory TransactionState.initial() => _TransactionState(
    latest: LatestTransactionsStatus.initial(),
    selectedTransaction: null,
  );

  TransactionState copyWith({
    LatestTransactionsStatus? latest,
    Object? selectedTransaction = _sentinel,
  }) => _TransactionState(
    latest: latest ?? this.latest,
    selectedTransaction: identical(selectedTransaction, _sentinel)
        ? this.selectedTransaction
        : selectedTransaction as TransactionEntity?,
  );

  @override
  List<Object?> get props => [latest, selectedTransaction];
}

final class _TransactionState extends TransactionState {
  @override
  final LatestTransactionsStatus latest;
  @override
  final TransactionEntity? selectedTransaction;

  const _TransactionState({
    required this.latest,
    required this.selectedTransaction,
  });
}

/// Loading/error/data status for the latest transactions list.
final class LatestTransactionsStatus extends Equatable {
  /// Whether the list is currently loading.
  final bool isLoadingLatest;

  /// The loaded transactions.
  final List<TransactionEntity> latestExpenses;

  /// Human-readable error message, if the last load failed.
  final String? latestError;

  const LatestTransactionsStatus({
    this.isLoadingLatest = false,
    this.latestExpenses = const [],
    this.latestError,
  });

  factory LatestTransactionsStatus.initial() =>
      const LatestTransactionsStatus();

  LatestTransactionsStatus copyWith({
    bool? isLoadingLatest,
    List<TransactionEntity>? latestExpenses,
    Object? latestError = _sentinel,
  }) {
    return LatestTransactionsStatus(
      isLoadingLatest: isLoadingLatest ?? this.isLoadingLatest,
      latestExpenses: latestExpenses ?? this.latestExpenses,
      latestError: identical(latestError, _sentinel)
          ? this.latestError
          : latestError as String?,
    );
  }

  @override
  List<Object?> get props => [isLoadingLatest, latestExpenses, latestError];
}
