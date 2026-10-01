import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
    on<DeleteTransaction>(_onDeleteTransaction);
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
      },
    );
  }

  void _onTransactionDetailsRequested(
    TransactionDetailsRequested event,
    Emitter<TransactionState> emit,
  ) {
    final transaction = state.latest.latestExpenses
        .cast<TransactionEntity?>()
        .firstWhere(
          (t) =>
              t?.id == event.expenseId ||
              t?.localId.toString() == event.expenseId,
          orElse: () => null,
        );
    emit(state.copyWith(selectedTransaction: transaction));
  }
}
