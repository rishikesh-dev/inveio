import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:inveio/transaction/domain/services/gst_calculator.dart';
import 'package:inveio/transaction/domain/services/gst_recalculator.dart';

/// Sentinel used by [copyWith] to distinguish "not provided" from explicit null.
const _unset = Object();

/// Immutable state that backs the add/edit invoice form.
@immutable
class InvoiceFormState extends Equatable {
  final double amount;
  final String clientGstin;
  final String? clientName;
  final String? invoiceNumber;
  final String description;
  final DateTime date;
  final DateTime? dueDate;
  final GstBreakdown gst;
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;

  const InvoiceFormState({
    this.amount = 0.0,
    this.clientGstin = '',
    this.clientName,
    this.invoiceNumber,
    this.description = '',
    required this.date,
    this.dueDate,
    required this.gst,
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
  });

  /// The empty state for a fresh invoice form.
  factory InvoiceFormState.initial() => InvoiceFormState(
    date: DateTime.now(),
    gst: const GstBreakdown(
      isInterState: false,
      cgst: 0.0,
      sgst: 0.0,
      igst: 0.0,
      taxableAmount: 0.0,
    ),
  );

  InvoiceFormState copyWith({
    double? amount,
    String? clientGstin,
    String? clientName,
    String? invoiceNumber,
    String? description,
    DateTime? date,
    Object? dueDate = _unset,
    GstBreakdown? gst,
    bool? isSaving,
    Object? saveError = _unset,
    bool? saveSuccess,
  }) {
    return InvoiceFormState(
      amount: amount ?? this.amount,
      clientGstin: clientGstin ?? this.clientGstin,
      clientName: clientName ?? this.clientName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: identical(dueDate, _unset)
          ? this.dueDate
          : dueDate as DateTime?,
      gst: gst ?? this.gst,
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
    clientGstin,
    clientName,
    invoiceNumber,
    description,
    date,
    dueDate,
    gst,
    isSaving,
    saveError,
    saveSuccess,
  ];
}

/// Cubit that owns the add/edit invoice form.
///
/// Mirrors `ExpenseFormCubit`: it talks to [TransactionRepository] directly and
/// never depends on `TransactionBloc`.
class InvoiceFormCubit extends Cubit<InvoiceFormState> {
  InvoiceFormCubit({
    required TransactionRepository transactionRepository,
    required OnboardingLocalDataSource onboardingLocalDataSource,
    required this.uid,
    GstCalculator? gstCalculator,
  }) : _transactionRepository = transactionRepository,
       _gstRecalculator = GstRecalculator(
         onboardingLocalDataSource: onboardingLocalDataSource,
         gstCalculator: gstCalculator ?? const GstCalculator(),
       ),
       super(InvoiceFormState.initial());

  final TransactionRepository _transactionRepository;
  final GstRecalculator _gstRecalculator;

  /// Owner of the transaction being created.
  final String uid;

  Future<void> amountChanged(String raw) async {
    final amount = double.tryParse(raw) ?? 0.0;
    await _emitWithGst(state.copyWith(amount: amount));
  }

  Future<void> clientGstinChanged(String value) async {
    await _emitWithGst(
      state.copyWith(clientGstin: value.trim().toUpperCase()),
    );
  }

  void descriptionChanged(String value) =>
      emit(state.copyWith(description: value));

  void clientNameChanged(String value) =>
      emit(state.copyWith(clientName: value));

  void invoiceNumberChanged(String value) =>
      emit(state.copyWith(invoiceNumber: value));

  void dateChanged(DateTime date) => emit(state.copyWith(date: date));

  void dueDateChanged(DateTime date) => emit(state.copyWith(dueDate: date));

  /// Prefills the form when editing an existing invoice.
  ///
  /// The GST breakdown is copied verbatim from the entity so the original split
  /// is preserved while editing.
  void populateFromEntity(TransactionEntity entity) {
    emit(
      state.copyWith(
        amount: entity.taxableAmount,
        clientGstin: entity.clientGstin ?? '',
        description: entity.description,
        date: entity.date,
        clientName: entity.clientName,
        invoiceNumber: entity.invoiceNumber,
        dueDate: entity.dueDate,
        gst: GstBreakdown(
          isInterState: entity.isInterState,
          cgst: entity.cgst,
          sgst: entity.sgst,
          igst: entity.igst,
          taxableAmount: entity.taxableAmount,
        ),
      ),
    );
  }

  /// Prefills the form from a scanned receipt/invoice.
  ///
  /// The GST breakdown is recalculated after setting amount/GSTIN (same fix as
  /// the expense form) and the description is set to `Purchase from <vendor>`.
  Future<void> populateFromScan(ScannedReceiptEntity data) async {
    final vendor = data.vendorName;
    await _emitWithGst(
      state.copyWith(
        amount: data.amount ?? 0.0,
        clientGstin: data.gstin ?? '',
        clientName: vendor,
        description: (vendor != null && vendor.isNotEmpty)
            ? 'Purchase from $vendor'
            : '',
        date: data.transactionDate ?? DateTime.now(),
      ),
    );
  }

  /// Persists the current form as an invoice transaction.
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

  Future<void> _emitWithGst(InvoiceFormState next) async {
    final breakdown = await _gstRecalculator.recalculate(
      taxableAmount: next.amount,
      counterpartyGstin: next.clientGstin,
    );
    emit(next.copyWith(gst: breakdown));
  }

  TransactionEntity _buildEntity() {
    final now = DateTime.now();
    return TransactionEntity(
      uid: uid,
      type: TransactionType.invoice,
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
      date: state.date,
      createdAt: now,
      updatedAt: now,
      clientName: state.clientName,
      clientGstin: state.clientGstin,
      invoiceNumber: state.invoiceNumber,
      paymentStatus: PaymentStatus.draft,
      dueDate: state.dueDate,
    );
  }
}
