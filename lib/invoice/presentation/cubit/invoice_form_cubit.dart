import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:inveio/transaction/domain/services/gst_calculator.dart';
import 'package:inveio/transaction/domain/services/gst_recalculator.dart';

/// Sentinel used by [copyWith] to distinguish "not provided" from explicit null.
const _unset = Object();

class InvoiceFormState extends Equatable {
  final double amount;
  final String clientGstin;
  final String? clientName;
  final String? invoiceNumber;
  final String description;
  final DateTime? date;
  final DateTime? dueDate;
  final GstBreakdown gst;
  final bool isLoading;
  final bool notFound;
  final String? editingId;
  final DateTime? createdAt;
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;

  /// Local path of the scanned receipt image attached to this invoice.
  final String? receiptPath;

  /// GST slab percentage used for the breakdown.
  final int gstSlab;

  /// Inline validation message shown under the amount field.
  final String? amountError;

  const InvoiceFormState({
    this.amount = 0.0,
    this.clientGstin = '',
    this.clientName,
    this.invoiceNumber,
    this.description = '',
    required this.date,
    this.dueDate,
    required this.gst,
    this.isLoading = false,
    this.notFound = false,
    this.editingId,
    this.createdAt,
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
    this.receiptPath,
    this.gstSlab = 18,
    this.amountError,
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
    gstSlab: 18,
  );

  InvoiceFormState copyWith({
    double? amount,
    String? clientGstin,
    String? clientName,
    String? invoiceNumber,
    String? description,
    Object? date = _unset,
    Object? dueDate = _unset,
    GstBreakdown? gst,
    bool? isLoading,
    bool? notFound,
    Object? editingId = _unset,
    Object? createdAt = _unset,
    bool? isSaving,
    Object? saveError = _unset,
    bool? saveSuccess,
    Object? receiptPath = _unset,
    Object? gstSlab = _unset,
    Object? amountError = _unset,
  }) {
    return InvoiceFormState(
      amount: amount ?? this.amount,
      clientGstin: clientGstin ?? this.clientGstin,
      clientName: clientName ?? this.clientName,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      description: description ?? this.description,
      date: identical(date, _unset) ? this.date : date as DateTime?,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      gst: gst ?? this.gst,
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
      receiptPath: identical(receiptPath, _unset)
          ? this.receiptPath
          : receiptPath as String?,
      gstSlab: identical(gstSlab, _unset) ? this.gstSlab : gstSlab as int,
      amountError: identical(amountError, _unset)
          ? this.amountError
          : amountError as String?,
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
    isLoading,
    notFound,
    editingId,
    createdAt,
    isSaving,
    saveError,
    saveSuccess,
    receiptPath,
    gstSlab,
    amountError,
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

  /// Identity of the invoice being edited, kept outside the state so the
  /// immutable [InvoiceFormState] stays free of persistence-only fields.
  TransactionEntity? _editingEntity;

  /// Tax-inclusive total from a scan, kept outside the state so rate changes
  /// can re-derive the taxable amount without adding tax on top. Cleared when
  /// the user edits the amount manually or loads an existing invoice.
  double? _scannedInclusiveTotal;

  /// Owner of the transaction being created.
  final String uid;

  Future<void> amountChanged(String raw) async {
    _scannedInclusiveTotal = null;
    final amount = double.tryParse(raw) ?? 0.0;
    await _emitWithGst(state.copyWith(amount: amount, amountError: null));
  }

  Future<void> clientGstinChanged(String value) async {
    await _emitWithGst(state.copyWith(clientGstin: value.trim().toUpperCase()));
  }

  void descriptionChanged(String value) =>
      emit(state.copyWith(description: value));

  void clientNameChanged(String value) =>
      emit(state.copyWith(clientName: value));

  void invoiceNumberChanged(String value) =>
      emit(state.copyWith(invoiceNumber: value));

  void dateChanged(DateTime date) => emit(state.copyWith(date: date));

  void dueDateChanged(DateTime date) => emit(state.copyWith(dueDate: date));

  void receiptAttached(String path) =>
      emit(state.copyWith(receiptPath: path));

  void receiptRemoved() => emit(state.copyWith(receiptPath: null));

  /// Changes the GST slab. When the amount came from a scan (tax-inclusive),
  /// the taxable value is re-derived from the original scanned total instead of
  /// layering tax on top of an already-recalculated amount.
  Future<void> gstRateChanged(int slab) async {
    final scannedTotal = _scannedInclusiveTotal;
    final next = state.copyWith(gstSlab: slab);
    if (scannedTotal != null) {
      final breakdown = await _gstRecalculator.recalculateFromInclusiveTotal(
        totalAmount: scannedTotal,
        counterpartyGstin: next.clientGstin,
        gstRate: slab / 100,
      );
      emit(next.copyWith(amount: breakdown.taxableAmount, gst: breakdown));
      return;
    }
    await _emitWithGst(next);
  }

  /// Loads an existing invoice for editing.
  ///
  /// Mirrors `ExpenseFormCubit.loadForEdit`: the saved GST values are restored
  /// verbatim rather than recalculated, and a missed lookup surfaces as
  /// [InvoiceFormState.notFound].
  ///
  /// [id] is the transaction's local Isar ID.
  Future<void> loadForEdit(String id) async {
    final localId = int.tryParse(id);
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
            amount: entity.taxableAmount,
            clientGstin: entity.clientGstin ?? '',
            clientName: entity.clientName,
            invoiceNumber: entity.invoiceNumber,
            description: entity.description,
            date: entity.date,
            dueDate: entity.dueDate,
            receiptPath: entity.receiptUrl,
            gstSlab: entity.gstSlab,
            gst: gstBreakdown,
          ),
        );
      },
    );
  }

  /// Prefills the form from a scanned receipt/invoice.
  ///
  /// The scanned amount is the printed total, so it already includes GST. The
  /// taxable value is back-calculated from it instead of adding tax on top.
  Future<void> populateFromScan(ParsedReceipt data) async {
    final vendor = data.vendor.value;
    final inclusiveTotal = data.amount.value;
    _scannedInclusiveTotal = inclusiveTotal;

    final next = state.copyWith(
      amount: inclusiveTotal ?? 0.0,
      amountError: null,
      clientGstin: data.gstin.value ?? '',
      clientName: vendor,
      description: (vendor != null && vendor.isNotEmpty)
          ? 'Purchase from $vendor'
          : '',
      date: data.date.value,
      gstSlab: 18,
    );

    if (inclusiveTotal == null) {
      await _emitWithGst(next);
      return;
    }

    final breakdown = await _gstRecalculator.recalculateFromInclusiveTotal(
      totalAmount: inclusiveTotal,
      counterpartyGstin: next.clientGstin,
      gstRate: next.gstSlab / 100,
    );
    emit(next.copyWith(amount: breakdown.taxableAmount, gst: breakdown));
  }

  /// Persists the current form as an invoice transaction.
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

  Future<void> _emitWithGst(InvoiceFormState next) async {
    final breakdown = await _gstRecalculator.recalculate(
      taxableAmount: next.amount,
      counterpartyGstin: next.clientGstin,
      gstRate: next.gstSlab / 100,
    );
    emit(next.copyWith(gst: breakdown));
  }

  TransactionEntity _buildEntity() {
    final now = DateTime.now();
    final editing = _editingEntity;
    return TransactionEntity(
      localId: editing?.localId,
      id: editing?.id,
      uid: uid,
      type: TransactionType.invoice,
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
      date: state.date!,
      createdAt: state.createdAt ?? now,
      updatedAt: now,
      clientName: state.clientName,
      clientGstin: state.clientGstin,
      invoiceNumber: state.invoiceNumber,
      receiptUrl: state.receiptPath,
      paymentStatus: PaymentStatus.draft,
      dueDate: state.dueDate,
    );
  }
}
