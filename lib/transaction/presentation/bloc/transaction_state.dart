part of 'transaction_bloc.dart';

const _sentinel = Object();

/// State for [TransactionBloc]: the latest/all transaction list status and the
/// transaction currently selected for the details screen.

sealed class TransactionState with Equatable {
  /// The latest/all transactions list status.
  LatestTransactionsStatus get latest;

  /// The invoice list status.
  InvoiceListStatus get invoices;

  /// The transaction selected for the details screen, if any.
  TransactionEntity? get selectedTransaction;

  const TransactionState();

  /// The initial, empty state.
  factory TransactionState.initial() => _TransactionState(
    latest: LatestTransactionsStatus.initial(),
    invoices: InvoiceListStatus.initial(),
    selectedTransaction: null,
  );

  TransactionState copyWith({
    LatestTransactionsStatus? latest,
    InvoiceListStatus? invoices,
    Object? selectedTransaction = _sentinel,
  }) => _TransactionState(
    latest: latest ?? this.latest,
    invoices: invoices ?? this.invoices,
    selectedTransaction: identical(selectedTransaction, _sentinel)
        ? this.selectedTransaction
        : selectedTransaction as TransactionEntity?,
  );

  @override
  List<Object?> get props => [latest, invoices, selectedTransaction];
}

final class _TransactionState extends TransactionState {
  @override
  final LatestTransactionsStatus latest;
  @override
  final InvoiceListStatus invoices;
  @override
  final TransactionEntity? selectedTransaction;

  const _TransactionState({
    required this.latest,
    required this.invoices,
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

/// Loading/error/data status for the invoices list.
final class InvoiceListStatus extends Equatable {
  /// Whether the invoice list is currently loading.
  final bool isLoadingInvoices;

  /// The loaded invoices.
  final List<TransactionEntity> invoices;

  /// Human-readable error message, if the last load failed.
  final String? invoicesError;

  const InvoiceListStatus({
    this.isLoadingInvoices = false,
    this.invoices = const [],
    this.invoicesError,
  });

  factory InvoiceListStatus.initial() => const InvoiceListStatus();

  InvoiceListStatus copyWith({
    bool? isLoadingInvoices,
    List<TransactionEntity>? invoices,
    Object? invoicesError = _sentinel,
  }) {
    return InvoiceListStatus(
      isLoadingInvoices: isLoadingInvoices ?? this.isLoadingInvoices,
      invoices: invoices ?? this.invoices,
      invoicesError: identical(invoicesError, _sentinel)
          ? this.invoicesError
          : invoicesError as String?,
    );
  }

  @override
  List<Object?> get props => [isLoadingInvoices, invoices, invoicesError];
}
