import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/expenses/domain/entities/expense_prefill.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:inveio/transaction/domain/services/gst_calculator.dart';
import 'package:inveio/transaction/domain/services/gst_recalculator.dart';

/// Sentinel used by [copyWith] to distinguish "not provided" from explicit null.
const _unset = Object();

/// Immutable state that backs the add/edit expense form.
@immutable
class ExpenseFormState extends Equatable {
  final double amount;
  final String counterpartyGstin;
  final String description;
  final DateTime date;
  final TimeOfDay? time;
  final String? category;
  final String? vendorName;
  final PaymentMode? paymentMode;
  final bool? itcEligible;
  final String? receiptPath;
  final GstBreakdown gst;
  final bool showCashWarning;
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;

  const ExpenseFormState({
    this.amount = 0.0,
    this.counterpartyGstin = '',
    this.description = '',
    required this.date,
    this.time,
    this.category,
    this.vendorName,
    this.paymentMode = PaymentMode.cash,
    this.itcEligible = true,
    this.receiptPath,
    required this.gst,
    this.showCashWarning = false,
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
  });

  /// The empty state for a fresh expense form.
  factory ExpenseFormState.initial() => ExpenseFormState(
    date: DateTime.now(),
    gst: const GstBreakdown(
      isInterState: false,
      cgst: 0.0,
      sgst: 0.0,
      igst: 0.0,
      taxableAmount: 0.0,
    ),
  );

  ExpenseFormState copyWith({
    double? amount,
    String? counterpartyGstin,
    String? description,
    DateTime? date,
    Object? time = _unset,
    Object? category = _unset,
    String? vendorName,
    PaymentMode? paymentMode,
    bool? itcEligible,
    Object? receiptPath = _unset,
    GstBreakdown? gst,
    bool? showCashWarning,
    bool? isSaving,
    Object? saveError = _unset,
    bool? saveSuccess,
  }) {
    return ExpenseFormState(
      amount: amount ?? this.amount,
      counterpartyGstin: counterpartyGstin ?? this.counterpartyGstin,
      description: description ?? this.description,
      date: date ?? this.date,
      time: identical(time, _unset) ? this.time : time as TimeOfDay?,
      category: identical(category, _unset)
          ? this.category
          : category as String?,
      vendorName: vendorName ?? this.vendorName,
      paymentMode: paymentMode ?? this.paymentMode,
      itcEligible: itcEligible ?? this.itcEligible,
      receiptPath: identical(receiptPath, _unset)
          ? this.receiptPath
          : receiptPath as String?,
      gst: gst ?? this.gst,
      showCashWarning: showCashWarning ?? this.showCashWarning,
      isSaving: isSaving ?? this.isSaving,
      saveError: identical(saveError, _unset)
          ? this.saveError
          : saveError as String?,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  @override
  List<Object?> get props => [
    amount,
    counterpartyGstin,
    description,
    date,
    time,
    category,
    vendorName,
    paymentMode,
    itcEligible,
    receiptPath,
    gst,
    showCashWarning,
    isSaving,
    saveError,
    saveSuccess,
  ];
}

/// Cubit that owns the add/edit expense form.
///
/// It replaces the form, GST and save responsibilities that used to live in
/// `TransactionBloc`, talks to [TransactionRepository] directly, and never
/// depends on `TransactionBloc` or the `scan` feature.
class ExpenseFormCubit extends Cubit<ExpenseFormState> {
  ExpenseFormCubit({
    required TransactionRepository transactionRepository,
    required OnboardingLocalDataSource onboardingLocalDataSource,
    required this.uid,
    GstCalculator? gstCalculator,
  }) : _transactionRepository = transactionRepository,
       _gstRecalculator = GstRecalculator(
         onboardingLocalDataSource: onboardingLocalDataSource,
         gstCalculator: gstCalculator ?? const GstCalculator(),
       ),
       super(ExpenseFormState.initial());

  final TransactionRepository _transactionRepository;
  final GstRecalculator _gstRecalculator;

  /// Owner of the transaction being created.
  final String uid;

  Future<void> amountChanged(String raw) async {
    final amount = double.tryParse(raw) ?? 0.0;
    await _emitWithGst(
      state.copyWith(
        amount: amount,
        showCashWarning:
            state.paymentMode == PaymentMode.cash && amount > 10000,
      ),
    );
  }

  Future<void> gstinChanged(String value) async {
    await _emitWithGst(
      state.copyWith(counterpartyGstin: value.trim().toUpperCase()),
    );
  }

  void descriptionChanged(String value) =>
      emit(state.copyWith(description: value));

  void vendorNameChanged(String value) =>
      emit(state.copyWith(vendorName: value));

  void dateChanged({DateTime? date, TimeOfDay? time}) =>
      emit(state.copyWith(date: date, time: time));

  void categorySelected(String category) =>
      emit(state.copyWith(category: category));

  void paymentModeSelected(PaymentMode mode) => emit(
    state.copyWith(
      paymentMode: mode,
      showCashWarning: mode == PaymentMode.cash && state.amount > 10000,
    ),
  );

  void itcEligibleToggled(bool value) =>
      emit(state.copyWith(itcEligible: value));

  void receiptAttached(String path) => emit(state.copyWith(receiptPath: path));

  void receiptRemoved() => emit(state.copyWith(receiptPath: null));

  /// Prefills the form from a scanned receipt.
  ///
  /// Fix 1: the GST breakdown is recalculated after setting amount/GSTIN (the
  /// old implementation never did, so the saved total was 0).
  /// Fix 2: the description is set to `Purchase from <vendor>` so that the
  /// displayed text and the persisted value match.
  Future<void> populateFromScan(ExpensePrefill prefill) async {
    final vendor = prefill.vendorName;
    await _emitWithGst(
      state.copyWith(
        amount: prefill.amount ?? 0.0,
        counterpartyGstin: prefill.gstin ?? '',
        vendorName: vendor,
        description: (vendor != null && vendor.isNotEmpty)
            ? 'Purchase from $vendor'
            : '',
        date: prefill.transactionDate ?? DateTime.now(),
      ),
    );
  }

  /// Persists the current form as an expense transaction.
  Future<void> save() async {
    emit(state.copyWith(isSaving: true, saveError: null, saveSuccess: false));
    final result = await _transactionRepository.upsertTransaction(
      _buildEntity(),
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, saveError: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, saveSuccess: true)),
    );
  }

  Future<void> _emitWithGst(ExpenseFormState next) async {
    final breakdown = await _gstRecalculator.recalculate(
      taxableAmount: next.amount,
      counterpartyGstin: next.counterpartyGstin,
    );
    emit(next.copyWith(gst: breakdown));
  }

  TransactionEntity _buildEntity() {
    final now = DateTime.now();
    return TransactionEntity(
      uid: uid,
      type: TransactionType.expense,
      totalAmount:
          state.gst.taxableAmount +
          state.gst.cgst +
          state.gst.sgst +
          state.gst.igst,
      taxableAmount: state.gst.taxableAmount,
      gstSlab: _gstRecalculator.gstSlab,
      isInterState: state.gst.isInterState,
      cgst: state.gst.cgst,
      sgst: state.gst.sgst,
      igst: state.gst.igst,
      description: state.description,
      date: _combineDateAndTime(state.date, state.time),
      createdAt: now,
      updatedAt: now,
      vendorName: state.vendorName,
      vendorGstin: state.counterpartyGstin,
      receiptUrl: state.receiptPath,
      category: state.category,
      paymentMode: state.paymentMode,
      itcEligible: state.itcEligible,
    );
  }

  static DateTime _combineDateAndTime(DateTime date, TimeOfDay? time) {
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
