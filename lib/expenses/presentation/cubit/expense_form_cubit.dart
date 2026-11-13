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

class ExpenseFormState extends Equatable {
  final double amount;
  final String counterpartyGstin;
  final String description;
  final DateTime? date;
  final TimeOfDay? time;
  final String? category;
  final String? vendorName;
  final PaymentMode? paymentMode;
  final bool? itcEligible;
  final String? receiptPath;
  final GstBreakdown gst;
  final bool showCashWarning;
  final bool isLoading;
  final bool notFound;
  final String? editingId;
  final DateTime? createdAt;
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;
  final int gstSlab;

  /// Inline validation message shown under the amount field.
  final String? amountError;

  /// Whether [gstSlab] is the scan fallback rather than a detected/user-picked
  /// rate. The form surfaces this so the user knows to verify it.
  final bool isGstRateDefault;

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
    this.isLoading = false,
    this.notFound = false,
    this.editingId,
    this.createdAt,
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
    this.gstSlab = 18,
    this.isGstRateDefault = false,
    this.amountError,
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
    gstSlab: 18,
  );

  ExpenseFormState copyWith({
    double? amount,
    String? counterpartyGstin,
    String? description,
    Object? date = _unset,
    Object? time = _unset,
    Object? category = _unset,
    String? vendorName,
    PaymentMode? paymentMode,
    bool? itcEligible,
    Object? receiptPath = _unset,
    GstBreakdown? gst,
    bool? showCashWarning,
    bool? isLoading,
    bool? notFound,
    Object? editingId = _unset,
    Object? createdAt = _unset,
    bool? isSaving,
    Object? saveError = _unset,
    bool? saveSuccess,
    Object? gstSlab = _unset,
    bool? isGstRateDefault,
    Object? amountError = _unset,
  }) {
    return ExpenseFormState(
      amount: amount ?? this.amount,
      counterpartyGstin: counterpartyGstin ?? this.counterpartyGstin,
      description: description ?? this.description,
      date: identical(date, _unset) ? this.date : date as DateTime?,
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
      isLoading: isLoading ?? this.isLoading,
      notFound: notFound ?? this.notFound,
      editingId: identical(editingId, _unset)
          ? this.editingId
          : editingId as String?,
      createdAt: identical(createdAt, _unset)
          ? this.createdAt
          : createdAt as DateTime?,
      isSaving: isSaving ?? this.isSaving,
      saveError: identical(saveError, _unset)
          ? this.saveError
          : saveError as String?,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      gstSlab: identical(gstSlab, _unset) ? this.gstSlab : gstSlab as int,
      isGstRateDefault: isGstRateDefault ?? this.isGstRateDefault,
      amountError: identical(amountError, _unset)
          ? this.amountError
          : amountError as String?,
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
    isLoading,
    notFound,
    editingId,
    createdAt,
    isSaving,
    saveError,
    saveSuccess,
    gstSlab,
    isGstRateDefault,
    amountError,
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

  /// Identity of the transaction being edited, kept outside the state so the
  /// immutable [ExpenseFormState] stays free of persistence-only fields.
  TransactionEntity? _editingEntity;

  /// Tax-inclusive total from a scan, kept outside the state so rate changes
  /// can re-derive the taxable amount without adding tax on top. Cleared when
  /// the user edits the amount manually or loads an existing expense.
  double? _scannedInclusiveTotal;

  /// Owner of the transaction being created.
  final String uid;

  Future<void> amountChanged(String raw) async {
    _scannedInclusiveTotal = null;
    final amount = double.tryParse(raw) ?? 0.0;
    await _emitWithGst(
      state.copyWith(
        amount: amount,
        amountError: null,
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

  Future<void> gstRateChanged(int slab) async {
    final scannedTotal = _scannedInclusiveTotal;
    if (scannedTotal != null) {
      final next = state.copyWith(gstSlab: slab, isGstRateDefault: false);
      final breakdown = await _gstRecalculator.recalculateFromInclusiveTotal(
        totalAmount: scannedTotal,
        counterpartyGstin: next.counterpartyGstin,
        gstRate: slab / 100,
      );
      emit(next.copyWith(amount: breakdown.taxableAmount, gst: breakdown));
      return;
    }
    await _emitWithGst(state.copyWith(gstSlab: slab, isGstRateDefault: false));
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
  /// The scanned amount is the printed total, so it already includes GST. The
  /// taxable value is back-calculated from it instead of adding tax on top.
  /// Fix 2: the description is set to `Purchase from <vendor>` so that the
  /// displayed text and the persisted value match.
  Future<void> populateFromScan(ExpensePrefill prefill) async {
    final vendor = prefill.vendorName;
    final inclusiveTotal = prefill.amount;
    _scannedInclusiveTotal = inclusiveTotal;

    final next = state.copyWith(
      amount: inclusiveTotal ?? 0.0,
      amountError: null,
      counterpartyGstin: prefill.gstin ?? '',
      vendorName: vendor,
      description: (vendor != null && vendor.isNotEmpty)
          ? 'Purchase from $vendor'
          : '',
      date: prefill.transactionDate,
      gstSlab: 18,
      isGstRateDefault: prefill.gstin?.isNotEmpty ?? false,
    );

    if (inclusiveTotal == null) {
      await _emitWithGst(next);
      return;
    }

    final breakdown = await _gstRecalculator.recalculateFromInclusiveTotal(
      totalAmount: inclusiveTotal,
      counterpartyGstin: next.counterpartyGstin,
      gstRate: next.gstSlab / 100,
    );
    emit(next.copyWith(amount: breakdown.taxableAmount, gst: breakdown));
  }

  /// Loads an existing expense for editing.
  ///
  /// The saved GST values are restored verbatim — they are never recalculated
  /// here, so the breakdown the user originally agreed to survives a round trip
  /// even if the onboarding state code changed in the meantime.
  ///
  /// [id] is the transaction's local Isar ID. When the lookup misses, the state
  /// flips [ExpenseFormState.notFound] so the screen can show a not-found view.
  Future<void> loadForEdit(String id) async {
    final localId = int.tryParse(id);
    _scannedInclusiveTotal = null;
    emit(state.copyWith(isLoading: true, notFound: false));

    if (localId == null) {
      emit(state.copyWith(isLoading: false, notFound: true));
      return;
    }

    final result = await _transactionRepository.getTransactionByLocalId(
      localId,
    );

    await result.fold(
      (failure) async =>
          emit(state.copyWith(isLoading: false, saveError: failure.message)),
      (entity) async {
        if (entity == null) {
          emit(state.copyWith(isLoading: false, notFound: true));
          return;
        }
        _editingEntity = entity;
        final total =
            entity.taxableAmount + entity.cgst + entity.sgst + entity.igst;
        final gstBreakdown = GstBreakdown(
          isInterState: entity.isInterState,
          cgst: entity.cgst,
          sgst: entity.sgst,
          igst: entity.igst,
          taxableAmount: entity.taxableAmount,
        );
        emit(
          state.copyWith(
            isLoading: false,
            notFound: false,
            editingId: entity.localId?.toString() ?? id,
            createdAt: entity.createdAt,
            amount: total,
            counterpartyGstin: entity.vendorGstin ?? '',
            description: entity.description,
            date: entity.date,
            time: TimeOfDay.fromDateTime(entity.date),
            category: entity.category,
            vendorName: entity.vendorName,
            paymentMode: entity.paymentMode,
            itcEligible: entity.itcEligible,
            receiptPath: entity.receiptUrl,
            gst: gstBreakdown,
            gstSlab: entity.gstSlab,
            isGstRateDefault: false,
          ),
        );
      },
    );
  }

  /// Persists the current form as an expense transaction.
  ///
  /// In edit mode the original local ID, server ID and [TransactionEntity.createdAt]
  /// are preserved so the save updates the existing row instead of inserting a
  /// duplicate; only `updatedAt` moves forward.
  Future<void> save() async {
    if (state.amount <= 0) {
      emit(
        state.copyWith(
          amountError: 'Amount must be greater than ₹0',
          saveSuccess: false,
        ),
      );
      return;
    }
    if (state.date == null) {
      emit(
        state.copyWith(
          saveError: 'Date not found, please set it',
          saveSuccess: false,
        ),
      );
      return;
    }
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
    final gstBreakdown = await _gstRecalculator.recalculate(
      taxableAmount: next.amount,
      counterpartyGstin: next.counterpartyGstin,
      gstRate: next.gstSlab / 100,
    );
    emit(next.copyWith(gst: gstBreakdown));
  }

  TransactionEntity _buildEntity() {
    final now = DateTime.now();
    final editing = _editingEntity;
    return TransactionEntity(
      localId: editing?.localId,
      id: editing?.id,
      uid: uid,
      type: TransactionType.expense,
      totalAmount:
          state.gst.taxableAmount +
          state.gst.cgst +
          state.gst.sgst +
          state.gst.igst,
      taxableAmount: state.gst.taxableAmount,
      gstSlab: state.gstSlab,
      isInterState: state.gst.isInterState,
      cgst: state.gst.cgst,
      sgst: state.gst.sgst,
      igst: state.gst.igst,
      description: state.description,
      date: _combineDateAndTime(state.date!, state.time),
      createdAt: state.createdAt ?? now,
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
