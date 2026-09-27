/// The type of transaction.
enum TransactionType { expense, invoice }

/// The payment mode used for an expense.
enum PaymentMode { cash, upi, card, bank }

/// The payment status of an invoice.
enum PaymentStatus { paid, pending, draft }

/// Core entity representing a financial transaction (expense or invoice).
class TransactionEntity {
  /// Local Isar database ID.
  final int? localId;

  /// Server-side document ID.
  final String? id;

  /// The user ID that owns this transaction.
  final String uid;

  /// Whether this is an expense or an invoice.
  final TransactionType type;

  /// Total amount including tax.
  final double totalAmount;

  /// Amount before tax.
  final double taxableAmount;

  /// GST slab percentage.
  final int gstSlab;

  /// Whether the transaction is inter-state (IGST) or intra-state (CGST+SGST).
  final bool isInterState;

  /// Central GST amount.
  final double cgst;

  /// State GST amount.
  final double sgst;

  /// Integrated GST amount (for inter-state transactions).
  final double igst;

  /// Description of the transaction.
  final String description;

  /// Date of the transaction.
  final DateTime date;

  // Expense only

  /// Vendor name for expense transactions.
  final String? vendorName;

  /// Vendor GSTIN for expense transactions.
  final String? vendorGstin;

  /// URL/path to the receipt image.
  final String? receiptUrl;

  /// Expense category label.
  final String? category;

  /// Payment mode used for the expense.
  final PaymentMode? paymentMode;

  /// Whether Input Tax Credit (ITC) is eligible for this expense.
  final bool? itcEligible;

  // Invoice only

  /// Client name for invoice transactions.
  final String? clientName;

  /// Client GSTIN for invoice transactions.
  final String? clientGstin;

  /// Invoice number.
  final String? invoiceNumber;

  /// Payment status of the invoice.
  final PaymentStatus? paymentStatus;

  /// Due date for invoice payment.
  final DateTime? dueDate;

  /// Path to the generated PDF invoice.
  final String? pdfPath;

  // Sync

  /// Whether this transaction has been synced to the cloud.
  final bool isSynced;

  /// Firestore document ID after sync.
  final String? firestoreId;

  /// Timestamp when the transaction was created.
  final DateTime createdAt;

  /// Timestamp when the transaction was last updated.
  final DateTime updatedAt;

  TransactionEntity({
    this.localId,
    this.id,
    required this.uid,
    required this.type,
    required this.totalAmount,
    required this.taxableAmount,
    required this.gstSlab,
    required this.isInterState,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.description,
    required this.date,
    this.vendorName,
    this.vendorGstin,
    this.receiptUrl,
    this.category,
    this.paymentMode,
    this.itcEligible,
    this.clientName,
    this.clientGstin,
    this.invoiceNumber,
    this.paymentStatus,
    this.dueDate,
    this.pdfPath,
    this.isSynced = false,
    this.firestoreId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this [TransactionEntity] with the given fields replaced.
  TransactionEntity copyWith({
    int? localId,
    String? id,
    String? uid,
    TransactionType? type,
    double? totalAmount,
    double? taxableAmount,
    int? gstSlab,
    bool? isInterState,
    double? cgst,
    double? sgst,
    double? igst,
    String? description,
    DateTime? date,
    String? vendorName,
    String? vendorGstin,
    String? receiptUrl,
    String? category,
    PaymentMode? paymentMode,
    bool? itcEligible,
    String? clientName,
    String? clientGstin,
    String? invoiceNumber,
    PaymentStatus? paymentStatus,
    DateTime? dueDate,
    String? pdfPath,
    bool? isSynced,
    String? firestoreId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionEntity(
      localId: localId ?? this.localId,
      id: id ?? this.id,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      totalAmount: totalAmount ?? this.totalAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      gstSlab: gstSlab ?? this.gstSlab,
      isInterState: isInterState ?? this.isInterState,
      cgst: cgst ?? this.cgst,
      sgst: sgst ?? this.sgst,
      igst: igst ?? this.igst,
      description: description ?? this.description,
      date: date ?? this.date,
      vendorName: vendorName ?? this.vendorName,
      vendorGstin: vendorGstin ?? this.vendorGstin,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      category: category ?? this.category,
      paymentMode: paymentMode ?? this.paymentMode,
      itcEligible: itcEligible ?? this.itcEligible,
      clientName: clientName ?? this.clientName,
      clientGstin: clientGstin ?? this.clientGstin,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      dueDate: dueDate ?? this.dueDate,
      pdfPath: pdfPath ?? this.pdfPath,
      isSynced: isSynced ?? this.isSynced,
      firestoreId: firestoreId ?? this.firestoreId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
