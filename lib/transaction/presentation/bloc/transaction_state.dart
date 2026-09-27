part of 'transaction_bloc.dart';

const _sentinel = Object();

@immutable
sealed class TransactionState with Equatable {
  TransactionFormData get form;
  GstBreakdown get gst;
  SaveStatus get save;
  LatestTransactionsStatus get latest;
  TransactionEntity? get selectedTransaction;
  bool get showCashWarning;

  const TransactionState();

  factory TransactionState.initial() => _TransactionState(
    form: TransactionFormData.initial(),
    gst: const GstBreakdown(
      isInterState: false,
      cgst: 0.0,
      sgst: 0.0,
      igst: 0.0,
      taxableAmount: 0.0,
    ),
    save: SaveStatus.initial(),
    latest: LatestTransactionsStatus.initial(),
    selectedTransaction: null,
    showCashWarning: false,
  );


  TransactionState copyWith({
    TransactionFormData? form,
    GstBreakdown? gst,
    SaveStatus? save,
    LatestTransactionsStatus? latest,
    Object? selectedTransaction = _sentinel,
    bool? showCashWarning,
  }) => _TransactionState(
    form: form ?? this.form,
    gst: gst ?? this.gst,
    save: save ?? this.save,
    latest: latest ?? this.latest,
    selectedTransaction: identical(selectedTransaction, _sentinel)
        ? this.selectedTransaction
        : selectedTransaction as TransactionEntity?,
    showCashWarning: showCashWarning ?? this.showCashWarning,
  );

  @override
  List<Object?> get props => [
    form,
    gst,
    save,
    latest,
    selectedTransaction,
    showCashWarning,
  ];
}

final class _TransactionState extends TransactionState {
  @override
  final TransactionFormData form;
  @override
  final GstBreakdown gst;
  @override
  final SaveStatus save;
  @override
  final LatestTransactionsStatus latest;
  @override
  final TransactionEntity? selectedTransaction;
  @override
  final bool showCashWarning;

  const _TransactionState({
    required this.form,
    required this.gst,
    required this.save,
    required this.latest,
    required this.selectedTransaction,
    required this.showCashWarning,
  });
}

final class TransactionFormData extends Equatable {
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
  final String? clientName;
  final String? invoiceNumber;
  final DateTime? dueDate;

  const TransactionFormData({
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
    this.clientName,
    this.invoiceNumber,
    this.dueDate,
  });

  factory TransactionFormData.initial() {
    return TransactionFormData(date: DateTime.now());
  }

  TransactionFormData copyWith({
    double? amount,
    String? counterpartyGstin,
    String? description,
    DateTime? date,
    Object? time = _sentinel,
    Object? category = _sentinel,
    Object? vendorName = _sentinel,
    PaymentMode? paymentMode,
    bool? itcEligible,
    Object? receiptPath = _sentinel,
    Object? clientName = _sentinel,
    Object? invoiceNumber = _sentinel,
    Object? dueDate = _sentinel,
  }) {
    return TransactionFormData(
      amount: amount ?? this.amount,
      counterpartyGstin: counterpartyGstin ?? this.counterpartyGstin,
      description: description ?? this.description,
      date: date ?? this.date,
      time: identical(time, _sentinel) ? this.time : time as TimeOfDay?,
      category: identical(category, _sentinel)
          ? this.category
          : category as String?,
      vendorName: identical(vendorName, _sentinel)
          ? this.vendorName
          : vendorName as String?,
      paymentMode: paymentMode ?? this.paymentMode,
      itcEligible: itcEligible ?? this.itcEligible,
      receiptPath: identical(receiptPath, _sentinel)
          ? this.receiptPath
          : receiptPath as String?,
      clientName: identical(clientName, _sentinel)
          ? this.clientName
          : clientName as String?,
      invoiceNumber: identical(invoiceNumber, _sentinel)
          ? this.invoiceNumber
          : invoiceNumber as String?,
      dueDate: identical(dueDate, _sentinel)
          ? this.dueDate
          : dueDate as DateTime?,
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
    clientName,
    invoiceNumber,
    dueDate,
  ];
}

final class SaveStatus extends Equatable {
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;

  const SaveStatus({
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
  });

  factory SaveStatus.initial() => const SaveStatus();

  SaveStatus copyWith({
    bool? isSaving,
    Object? saveError = _sentinel,
    bool? saveSuccess,
  }) {
    return SaveStatus(
      isSaving: isSaving ?? this.isSaving,
      saveError: identical(saveError, _sentinel)
          ? this.saveError
          : saveError as String?,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  @override
  List<Object?> get props => [isSaving, saveError, saveSuccess];
}

final class LatestTransactionsStatus extends Equatable {
  final bool isLoadingLatest;
  final List<TransactionEntity> latestExpenses;
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
