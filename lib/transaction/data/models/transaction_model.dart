import 'package:inveio/transaction/domain/entities/transaction_entity.dart';

import 'package:isar_community/isar.dart';
part 'transaction_model.g.dart';

/// Isar collection model for persisting transactions locally.
@collection
class TransactionModel {
  /// Auto-incremented Isar ID.
  late Id isarId = Isar.autoIncrement;

  /// Server-side document ID.
  @Index()
  late String? id;

  /// The user ID that owns this transaction.
  @Index()
  late String uid;

  /// Whether this is an expense or an invoice.
  @Enumerated(EnumType.name)
  late TransactionType type;

  /// Total amount including tax.
  late double totalAmount;

  /// Amount before tax.
  late double taxableAmount;

  /// GST slab percentage.
  late int gstSlab;

  /// Whether the transaction is inter-state (IGST) or intra-state (CGST+SGST).
  late bool isInterState;

  /// Central GST amount.
  late double cgst;

  /// State GST amount.
  late double sgst;

  /// Integrated GST amount (for inter-state transactions).
  late double igst;

  /// Description of the transaction.
  late String description;

  /// Date of the transaction.
  late DateTime date;

  // Expense only

  /// Vendor name for expense transactions.
  late String? vendorName;

  /// Vendor GSTIN for expense transactions.
  late String? vendorGstin;

  /// URL/path to the receipt image.
  late String? receiptUrl;

  /// Expense category label.
  late String? category;

  /// Payment mode used for the expense.
  @Enumerated(EnumType.name)
  late PaymentMode? paymentMode;

  /// Whether Input Tax Credit (ITC) is eligible for this expense.
  bool? itcEligible;

  // Invoice only

  /// Client name for invoice transactions.
  late String? clientName;

  /// Client GSTIN for invoice transactions.
  late String? clientGstin;

  /// Invoice number.
  late String? invoiceNumber;

  /// Payment status of the invoice.
  @Enumerated(EnumType.name)
  late PaymentStatus? paymentStatus;

  /// Due date for invoice payment.
  late DateTime? dueDate;

  /// Path to the generated PDF invoice.
  late String? pdfPath;

  // Sync

  /// Whether this transaction has been synced to the cloud.
  late bool isSynced;

  /// Firestore document ID after sync.
  late String? firestoreId;

  /// Timestamp when the transaction was created.
  late DateTime createdAt;

  /// Timestamp when the transaction was last updated.
  late DateTime updatedAt;

  /// Converts this model to a [TransactionEntity].
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      uid: uid,
      type: type,
      totalAmount: totalAmount,
      taxableAmount: taxableAmount,
      gstSlab: gstSlab,
      isInterState: isInterState,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      description: description,
      date: date,
      vendorName: vendorName,
      vendorGstin: vendorGstin,
      receiptUrl: receiptUrl,
      category: category,
      paymentMode: paymentMode,
      itcEligible: itcEligible,
      clientName: clientName,
      clientGstin: clientGstin,
      invoiceNumber: invoiceNumber,
      paymentStatus: paymentStatus,
      dueDate: dueDate,
      pdfPath: pdfPath,
      isSynced: isSynced,
      firestoreId: firestoreId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [TransactionModel] from a [TransactionEntity].
  static TransactionModel fromEntity(TransactionEntity entity) {
    final model = TransactionModel();
    model.isarId = entity.localId ?? Isar.autoIncrement;
    model.id = entity.id;
    model.uid = entity.uid;
    model.type = entity.type;
    model.totalAmount = entity.totalAmount;
    model.taxableAmount = entity.taxableAmount;
    model.gstSlab = entity.gstSlab;
    model.isInterState = entity.isInterState;
    model.cgst = entity.cgst;
    model.sgst = entity.sgst;
    model.igst = entity.igst;
    model.description = entity.description;
    model.date = entity.date;
    model.vendorName = entity.vendorName;
    model.vendorGstin = entity.vendorGstin;
    model.receiptUrl = entity.receiptUrl;
    model.category = entity.category;
    model.paymentMode = entity.paymentMode;
    model.itcEligible = entity.itcEligible;
    model.clientName = entity.clientName;
    model.clientGstin = entity.clientGstin;
    model.invoiceNumber = entity.invoiceNumber;
    model.paymentStatus = entity.paymentStatus;
    model.dueDate = entity.dueDate;
    model.pdfPath = entity.pdfPath;
    model.isSynced = entity.isSynced;
    model.firestoreId = entity.firestoreId;
    model.createdAt = entity.createdAt;
    model.updatedAt = entity.updatedAt;
    return model;
  }
}
