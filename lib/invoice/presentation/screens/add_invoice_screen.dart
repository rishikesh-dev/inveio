import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/theme/app_text_styles.dart';
import 'package:inveio/expenses/presentation/widgets/expense_input_fields.dart';
import 'package:inveio/invoice/presentation/widgets/add_invoice_form_fields.dart';
import 'package:inveio/invoice/presentation/widgets/invoice_gst_display.dart';
import 'package:inveio/invoice/presentation/widgets/invoice_save_button.dart';
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Screen for adding a new invoice transaction.
class AddInvoiceScreen extends StatefulWidget {
  final TransactionEntity? initialTransaction;
  final ScannedReceiptEntity? scannedData;

  const AddInvoiceScreen({
    super.key,
    this.initialTransaction,
    this.scannedData,
  });

  @override
  State<AddInvoiceScreen> createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _gstinController;
  late final TextEditingController _clientNameController;
  late final TextEditingController _invoiceNumberController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.scannedData?.amount?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.scannedData?.vendorName != null
          ? 'Purchase from ${widget.scannedData!.vendorName}'
          : '',
    );
    _gstinController = TextEditingController(text: widget.scannedData?.gstin);
    _clientNameController = TextEditingController(
      text: widget.scannedData?.vendorName,
    );
    _invoiceNumberController = TextEditingController();

    if (widget.initialTransaction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransactionBloc>().add(
          PopulateInvoiceForm(widget.initialTransaction!),
        );
      });
    } else if (widget.scannedData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransactionBloc>().add(
          PopulateFromScan(widget.scannedData!),
        );
      });
    } else {
      context.read<TransactionBloc>().add(const ResetForm());
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _gstinController.dispose();
    _clientNameController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTransaction != null;
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state.save.saveSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invoice saved')));
          if (context.mounted) context.pop();
        } else if (state.save.saveError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.save.saveError!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const AppBarWidget(sliver: false),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? 'Edit Invoice' : 'New Invoice',
                    style: const TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: IntrinsicWidth(
                      child: TextFieldWidget(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        hintText: '0',
                        textStyle: AppTextStyles.monoLarge.copyWith(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkTextPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          hintText: '0',
                          hintStyle: AppTextStyles.monoLarge.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkTextMuted,
                          ),
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                            size: 36,
                            color: AppColors.primary.withValues(alpha: 0.7),
                          ),
                        ),
                        onChanged: (value) => context
                            .read<TransactionBloc>()
                            .add(AmountChanged(value)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const InvoiceFieldLabel('Date'),
                  const SizedBox(height: 8),
                  InvoiceDateField(date: state.form.date, onTap: _pickDate),
                  const SizedBox(height: 16),
                  const InvoiceFieldLabel('Description'),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    controller: _descriptionController,
                    hintText: 'What is this invoice for?',
                    textStyle: const TextStyle(
                      color: AppColors.darkTextPrimary,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: expenseInputDecoration(
                      hint: 'What is this invoice for?',
                    ),
                    onChanged: (value) => context.read<TransactionBloc>().add(
                      DescriptionChanged(value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InvoiceFieldLabel('Client Name'),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    controller: _clientNameController,
                    hintText: 'Client name',
                    textStyle: const TextStyle(
                      color: AppColors.darkTextPrimary,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: expenseInputDecoration(hint: 'Client name'),
                    onChanged: (value) => context.read<TransactionBloc>().add(
                      ClientNameChanged(value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InvoiceFieldLabel('Invoice Number'),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    hintText: 'INV-001',
                    controller: _invoiceNumberController,
                    textStyle: const TextStyle(
                      color: AppColors.darkTextPrimary,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: expenseInputDecoration(hint: 'INV-001'),
                    onChanged: (value) => context.read<TransactionBloc>().add(
                      InvoiceNumberChanged(value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const InvoiceFieldLabel('Due Date'),
                  const SizedBox(height: 8),
                  InvoiceDueDateField(
                    dueDate: state.form.dueDate,
                    onTap: _pickDueDate,
                  ),
                  const SizedBox(height: 16),
                  const InvoiceFieldLabel('Client GSTIN'),
                  const SizedBox(height: 8),
                  TextFieldWidget(
                    controller: _gstinController,
                    hintText: 'GSTIN (optional)',
                    maxLength: 15,
                    textCapitalization: TextCapitalization.characters,
                    textStyle: const TextStyle(
                      color: AppColors.darkTextPrimary,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: expenseInputDecoration(
                      hint: 'GSTIN (optional)',
                    ),
                    onChanged: (value) => context.read<TransactionBloc>().add(
                      GstinChanged(value),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InvoiceGstDisplay(
                    cgst: state.gst.cgst,
                    sgst: state.gst.sgst,
                    igst: state.gst.igst,
                    taxableAmount: state.gst.taxableAmount,
                    isInterState: state.gst.isInterState,
                  ),
                  const SizedBox(height: 32),
                  InvoiceSaveButton(
                    isSaving: state.save.isSaving,
                    onPressed: () {
                      context.read<TransactionBloc>().add(
                        const UpsertTransaction(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final current = context.read<TransactionBloc>().state;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.form.date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      context.read<TransactionBloc>().add(DateChanged(date: picked));
    }
  }

  Future<void> _pickDueDate() async {
    final current = context.read<TransactionBloc>().state;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          current.form.dueDate ??
          current.form.date.add(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      context.read<TransactionBloc>().add(DueDateChanged(picked));
    }
  }
}
