import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:inveio/transaction/domain/services/gst_calculator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;
  final OnboardingLocalDataSource _onboardingLocalDatasource;
  final GstCalculator _gstCalculator;

  final String uid;
  final double gstRate;
  final TransactionType type;

  TransactionBloc({
    required TransactionRepository transactionRepository,
    required OnboardingLocalDataSource onboardingLocalDatasource,
    required this.uid,
    this.gstRate = 0.18,
    required this.type,
    GstCalculator? gstCalculator,
  }) : _transactionRepository = transactionRepository,
       _onboardingLocalDatasource = onboardingLocalDatasource,
       _gstCalculator = gstCalculator ?? const GstCalculator(),
       super(TransactionState.initial()) {
    on<AmountChanged>(_onAmountChanged);
    on<GstinChanged>(_onGstinChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<VendorNameChanged>(_onVendorNameChanged);
    on<ClientNameChanged>(_onClientNameChanged);
    on<InvoiceNumberChanged>(_onInvoiceNumberChanged);
    on<DateChanged>(_onDateChanged);
    on<DueDateChanged>(_onDueDateChanged);
    on<CategorySelected>(_onCategorySelected);
    on<PaymentModeSelected>(_onPaymentModeSelected);
    on<ItcEligibleToggled>(_onItcEligibleToggled);
    on<ReceiptAttached>(_onReceiptAttached);
    on<ReceiptRemoved>(_onReceiptRemoved);
    on<UpsertTransaction>(_onUpsertTransaction);
    on<ResetForm>(_onResetForm);
    on<LatestTransactionsRequested>(_onLatestTransactionsRequested);
    on<AllTransactionsRequested>(_onAllTransactionsRequested);
    on<PopulateInvoiceForm>(_onPopulateInvoiceForm);
    on<PopulateFromScan>(_onPopulateFromScan);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<TransactionDetailsRequested>(_onTransactionDetailsRequested);
  }

  Future<void> _onAmountChanged(
    AmountChanged event,
    Emitter<TransactionState> emit,
  ) async {
    final amount = double.tryParse(event.raw) ?? 0.0;
    await _emitWithGst(
      emit,
      state.copyWith(
        form: state.form.copyWith(amount: amount),
        showCashWarning: state.form.paymentMode == PaymentMode.cash && amount > 10000,
      ),
    );
  }

  Future<void> _onGstinChanged(
    GstinChanged event,
    Emitter<TransactionState> emit,
  ) async {
    await _emitWithGst(
      emit,
      state.copyWith(
        form: state.form.copyWith(
          counterpartyGstin: event.value.trim().toUpperCase(),
        ),
      ),
    );
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(form: state.form.copyWith(description: event.value)));
  }

  void _onVendorNameChanged(
    VendorNameChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(form: state.form.copyWith(vendorName: event.value)));
  }

  void _onClientNameChanged(
    ClientNameChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(form: state.form.copyWith(clientName: event.value)));
  }

  void _onInvoiceNumberChanged(
    InvoiceNumberChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(
      state.copyWith(form: state.form.copyWith(invoiceNumber: event.value)),
    );
  }

  void _onDateChanged(
    DateChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(
      state.copyWith(
        form: state.form.copyWith(date: event.date, time: event.time),
      ),
    );
  }

  void _onDueDateChanged(
    DueDateChanged event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(form: state.form.copyWith(dueDate: event.date)));
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(form: state.form.copyWith(category: event.category)));
  }

  void _onPaymentModeSelected(
    PaymentModeSelected event,
    Emitter<TransactionState> emit,
  ) {
    emit(
      state.copyWith(
        form: state.form.copyWith(paymentMode: event.mode),
        showCashWarning: event.mode == PaymentMode.cash && state.form.amount > 10000,
      ),
    );
  }

  void _onItcEligibleToggled(
    ItcEligibleToggled event,
    Emitter<TransactionState> emit,
  ) {
    emit(
      state.copyWith(form: state.form.copyWith(itcEligible: event.value)),
    );
  }

  void _onReceiptAttached(
    ReceiptAttached event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(form: state.form.copyWith(receiptPath: event.path)));
  }

  void _onReceiptRemoved(
    ReceiptRemoved event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(form: state.form.copyWith(receiptPath: null)));
  }

  Future<void> _onUpsertTransaction(
    UpsertTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        save: state.save.copyWith(
          isSaving: true,
          saveSuccess: false,
          saveError: null,
        ),
      ),
    );

    final result = await _transactionRepository.upsertTransaction(
      _buildEntity(),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          save: state.save.copyWith(
            isSaving: false,
            saveError: failure.message,
          ),
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            save: state.save.copyWith(isSaving: false, saveSuccess: true),
          ),
        );
        add(const LatestTransactionsRequested());
      },
    );
  }

  void _onResetForm(
    ResetForm event,
    Emitter<TransactionState> emit,
  ) {
    emit(TransactionState.initial());
  }

  Future<void> _onLatestTransactionsRequested(
    LatestTransactionsRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        latest: state.latest.copyWith(
          isLoadingLatest: true,
          latestError: null,
        ),
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
        latest: state.latest.copyWith(
          isLoadingLatest: true,
          latestError: null,
        ),
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

  void _onPopulateInvoiceForm(
    PopulateInvoiceForm event,
    Emitter<TransactionState> emit,
  ) {
    final e = event.entity;
    emit(
      state.copyWith(
        form: state.form.copyWith(
          amount: e.taxableAmount,
          counterpartyGstin: e.clientGstin ?? '',
          description: e.description,
          date: e.date,
          clientName: e.clientName,
          invoiceNumber: e.invoiceNumber,
          dueDate: e.dueDate,
        ),
        gst: GstBreakdown(
          isInterState: e.isInterState,
          cgst: e.cgst,
          sgst: e.sgst,
          igst: e.igst,
          taxableAmount: e.taxableAmount,
        ),
      ),
    );
  }

  void _onPopulateFromScan(
    PopulateFromScan event,
    Emitter<TransactionState> emit,
  ) {
    final d = event.data;
    emit(
      state.copyWith(
        form: state.form.copyWith(
          amount: d.amount ?? 0.0,
          counterpartyGstin: d.gstin ?? '',
          description: d.vendorName ?? '',
          date: d.transactionDate ?? DateTime.now(),
          vendorName: d.vendorName,
        ),
      ),
    );
  }

  Future<void> _emitWithGst(
    Emitter<TransactionState> emit,
    TransactionState next,
  ) async {
    final sellerStateCode = await _onboardingLocalDatasource.getStateCode();
    final breakdown = _gstCalculator.calculate(
      taxableAmount: next.form.amount,
      counterpartyGstin: next.form.counterpartyGstin,
      sellerStateCode: sellerStateCode,
      gstRate: gstRate,
    );

    emit(next.copyWith(gst: breakdown));
  }

  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(
      state.copyWith(
        save: state.save.copyWith(isSaving: true, saveError: null),
      ),
    );
    final result = await _transactionRepository.deleteTransaction(
      event.localId,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          save: state.save.copyWith(
            isSaving: false,
            saveError: failure.message,
          ),
        ),
      ),
      (_) {
        emit(
          state.copyWith(
            save: state.save.copyWith(isSaving: false, saveSuccess: true),
          ),
        );
        add(const LatestTransactionsRequested());
      },
    );
  }

  void _onTransactionDetailsRequested(
    TransactionDetailsRequested event,
    Emitter<TransactionState> emit,
  ) {
    final transaction = state.latest.latestExpenses.cast<TransactionEntity?>().firstWhere(
      (t) => t?.id == event.expenseId || t?.localId.toString() == event.expenseId,
      orElse: () => null,
    );
    emit(state.copyWith(selectedTransaction: transaction));
  }

  static DateTime _combineDateAndTime(DateTime date, TimeOfDay? time) {
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  TransactionEntity _buildEntity() {
    final now = DateTime.now();

    final base = TransactionEntity(
      uid: uid,
      type: type,
      totalAmount: state.gst.taxableAmount +
          state.gst.cgst +
          state.gst.sgst +
          state.gst.igst,
      taxableAmount: state.gst.taxableAmount,
      gstSlab: (gstRate * 100).round(),
      isInterState: state.gst.isInterState,
      cgst: state.gst.cgst,
      sgst: state.gst.sgst,
      igst: state.gst.igst,
      description: state.form.description,
      date: _combineDateAndTime(state.form.date, state.form.time),
      createdAt: now,
      updatedAt: now,
    );

    if (type == TransactionType.expense) {
      return base.copyWith(
        vendorName: state.form.vendorName,
        vendorGstin: state.form.counterpartyGstin,
        receiptUrl: state.form.receiptPath,
        category: state.form.category,
        paymentMode: state.form.paymentMode,
        itcEligible: state.form.itcEligible,
      );
    } else {
      return base.copyWith(
        clientName: state.form.clientName,
        clientGstin: state.form.counterpartyGstin,
        invoiceNumber: state.form.invoiceNumber,
        paymentStatus: PaymentStatus.draft,
        dueDate: state.form.dueDate,
      );
    }
  }
}
