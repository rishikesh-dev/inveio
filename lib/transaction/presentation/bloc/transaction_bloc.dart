import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

/// Bloc that owns the read/delete side of transactions: the latest/all lists,
/// the transaction selected for the details screen, and deletion.
///
/// Expense and invoice *form* concerns (amount, GST, saving) live in their own
/// cubits — `ExpenseFormCubit` and `InvoiceFormCubit`.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  /// Owner of the transactions being listed.
  final String uid;

  TransactionBloc({
    required TransactionRepository transactionRepository,
    required this.uid,
  }) : _transactionRepository = transactionRepository,
       super(TransactionState.initial()) {
    on<LatestTransactionsRequested>(_onLatestTransactionsRequested);
    on<AllTransactionsRequested>(_onAllTransactionsRequested);
    on<AllInvoicesRequested>(_onAllInvoicesRequested);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<ClearHistory>(_onClearHistory);
    on<TransactionDetailsRequested>(_onTransactionDetailsRequested);
  }

  Future<void> _onLatestTransactionsRequested(
    LatestTransactionsRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        latest: state.latest.copyWith(isLoadingLatest: true, latestError: null),
      ),
    );

    final result = await _transactionRepository.getLatestTransactions(
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          latest: state.latest.copyWith(
            isLoadingLatest: false,
            latestError: failure.message,
          ),
        ),
      ),
      (transactions) => emit(
        state.copyWith(
          latest: state.latest.copyWith(
            isLoadingLatest: false,
            latestExpenses: transactions,
          ),
        ),
      ),
    );
  }

  Future<void> _onAllTransactionsRequested(
    AllTransactionsRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        latest: state.latest.copyWith(isLoadingLatest: true, latestError: null),
      ),
    );

    final result = await _transactionRepository.getAllTransactions();

    result.fold(
      (failure) => emit(
        state.copyWith(
          latest: state.latest.copyWith(
            isLoadingLatest: false,
            latestError: failure.message,
          ),
        ),
      ),
      (transactions) => emit(
        state.copyWith(
          latest: state.latest.copyWith(
            isLoadingLatest: false,
            latestExpenses: transactions,
          ),
        ),
      ),
    );
  }

  Future<void> _onAllInvoicesRequested(
    AllInvoicesRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        invoices: state.invoices.copyWith(
          isLoadingInvoices: true,
          invoicesError: null,
        ),
      ),
    );

    final result = await _transactionRepository.getAllTransactions(
      type: TransactionType.invoice,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          invoices: state.invoices.copyWith(
            isLoadingInvoices: false,
            invoicesError: failure.message,
          ),
        ),
      ),
      (invoices) => emit(
        state.copyWith(
          invoices: state.invoices.copyWith(
            isLoadingInvoices: false,
            invoices: invoices,
          ),
        ),
      ),
    );
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await _transactionRepository.deleteTransaction(
      event.localId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          latest: state.latest.copyWith(latestError: failure.message),
        ),
      ),
      (_) {
        add(const LatestTransactionsRequested());
        add(const AllInvoicesRequested());
      },
    );
  }

  void _onTransactionDetailsRequested(
    TransactionDetailsRequested event,
    Emitter<TransactionState> emit,
  ) {
    final transaction = state.latest.latestExpenses
        .cast<TransactionEntity?>()
        .firstWhere((t) => t?.localId == event.localId, orElse: () => null);
    emit(state.copyWith(selectedTransaction: transaction));
  }

  Future<void> _onClearHistory(
    ClearHistory event,
    Emitter<TransactionState> emit,
  ) async {
    // Enforce the typed confirmation in the bloc too, so a caller that skips
    // the dialog cannot clear history.
    if (event.confirmation != 'DELETE') return;

    final result = await _transactionRepository.clearHistory();
    result.fold(
      (failure) => emit(
        state.copyWith(
          latest: state.latest.copyWith(latestError: failure.message),
        ),
      ),
      (_) {
        add(const AllTransactionsRequested());
        add(const AllInvoicesRequested());
      },
    );
  }
}
