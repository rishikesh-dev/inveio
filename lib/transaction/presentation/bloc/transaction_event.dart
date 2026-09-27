part of 'transaction_bloc.dart';

@immutable
sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

final class AmountChanged extends TransactionEvent {
  final String raw;

  const AmountChanged(this.raw);

  @override
  List<Object?> get props => [raw];
}

final class GstinChanged extends TransactionEvent {
  final String value;

  const GstinChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class DescriptionChanged extends TransactionEvent {
  final String value;

  const DescriptionChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class VendorNameChanged extends TransactionEvent {
  final String value;

  const VendorNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class ClientNameChanged extends TransactionEvent {
  final String value;

  const ClientNameChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class InvoiceNumberChanged extends TransactionEvent {
  final String value;

  const InvoiceNumberChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class DateChanged extends TransactionEvent {
  final DateTime? date;
  final TimeOfDay? time;

  const DateChanged({this.date, this.time});

  @override
  List<Object?> get props => [date, time];
}

final class DueDateChanged extends TransactionEvent {
  final DateTime date;

  const DueDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

final class CategorySelected extends TransactionEvent {
  final String category;

  const CategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}

final class PaymentModeSelected extends TransactionEvent {
  final PaymentMode mode;

  const PaymentModeSelected(this.mode);

  @override
  List<Object?> get props => [mode];
}

final class ItcEligibleToggled extends TransactionEvent {
  final bool value;

  const ItcEligibleToggled(this.value);

  @override
  List<Object?> get props => [value];
}

final class ReceiptAttached extends TransactionEvent {
  final String path;

  const ReceiptAttached(this.path);

  @override
  List<Object?> get props => [path];
}

final class ReceiptRemoved extends TransactionEvent {
  const ReceiptRemoved();
}

final class UpsertTransaction extends TransactionEvent {
  const UpsertTransaction();
}

final class ResetForm extends TransactionEvent {
  const ResetForm();
}

final class LatestTransactionsRequested extends TransactionEvent {
  final int limit;

  const LatestTransactionsRequested({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

final class AllTransactionsRequested extends TransactionEvent {
  const AllTransactionsRequested();
}

final class PopulateInvoiceForm extends TransactionEvent {
  final TransactionEntity entity;

  const PopulateInvoiceForm(this.entity);

  @override
  List<Object?> get props => [entity];
}

final class DeleteTransaction extends TransactionEvent {
  final int localId;

  const DeleteTransaction(this.localId);

  @override
  List<Object?> get props => [localId];
}

final class TransactionDetailsRequested extends TransactionEvent {
  final String expenseId;

  const TransactionDetailsRequested(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

final class PopulateFromScan extends TransactionEvent {
  final ScannedReceiptEntity data;

  const PopulateFromScan(this.data);

  @override
  List<Object?> get props => [data];
}
