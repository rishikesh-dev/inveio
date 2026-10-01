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
import 'package:inveio/invoice/presentation/cubit/invoice_form_cubit.dart';
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
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _gstinController = TextEditingController();
    _clientNameController = TextEditingController();
    _invoiceNumberController = TextEditingController();

    final initialTransaction = widget.initialTransaction;
    final scannedData = widget.scannedData;
    if (initialTransaction != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<InvoiceFormCubit>().populateFromEntity(initialTransaction);
      });
    } else if (scannedData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<InvoiceFormCubit>().populateFromScan(scannedData);
      });
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

  /// Syncs the text controllers from cubit state (used for prefill).
  ///
  /// Only writes when the value differs so the user's cursor/typing is kept.
  void _syncFromState(InvoiceFormState state) {
    final amountText = _amountController.text;
    if ((double.tryParse(amountText) ?? 0.0) != state.amount) {
      _setControllerText(
        _amountController,
        state.amount == 0.0 ? '' : state.amount.toString(),
      );
    }
    _setControllerText(_descriptionController, state.description);
    _setControllerText(_gstinController, state.clientGstin);
    _setControllerText(_clientNameController, state.clientName ?? '');
    _setControllerText(_invoiceNumberController, state.invoiceNumber ?? '');
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTransaction != null;
    return BlocListener<InvoiceFormCubit, InvoiceFormState>(
      listenWhen: (previous, current) =>
          previous.saveSuccess != current.saveSuccess ||
          previous.saveError != current.saveError,
      listener: (context, state) {
        if (state.saveSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Invoice saved')));
          context.read<TransactionBloc>().add(
            const LatestTransactionsRequested(),
          );
          if (context.mounted) context.pop();
        } else if (state.saveError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.saveError!)));
        }
      },
      child: BlocListener<InvoiceFormCubit, InvoiceFormState>(
        listenWhen: (previous, current) =>
            previous.amount != current.amount ||
            previous.description != current.description ||
            previous.clientGstin != current.clientGstin ||
            previous.clientName != current.clientName ||
            previous.invoiceNumber != current.invoiceNumber,
        listener: (context, state) => _syncFromState(state),
        child: BlocBuilder<InvoiceFormCubit, InvoiceFormState>(
          builder: (context, state) {
            return Scaffold(
              appBar: const AppBarWidget(sliver: false),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
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
                                .read<InvoiceFormCubit>()
                                .amountChanged(value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const InvoiceFieldLabel('Date'),
                      const SizedBox(height: 8),
                      InvoiceDateField(date: state.date, onTap: _pickDate),
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
                        onChanged: (value) => context
                            .read<InvoiceFormCubit>()
                            .descriptionChanged(value),
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
                        onChanged: (value) => context
                            .read<InvoiceFormCubit>()
                            .clientNameChanged(value),
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
                        onChanged: (value) => context
                            .read<InvoiceFormCubit>()
                            .invoiceNumberChanged(value),
                      ),
                      const SizedBox(height: 16),
                      const InvoiceFieldLabel('Due Date'),
                      const SizedBox(height: 8),
                      InvoiceDueDateField(
                        dueDate: state.dueDate,
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
                        onChanged: (value) => context
                            .read<InvoiceFormCubit>()
                            .clientGstinChanged(value),
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
                        isSaving: state.isSaving,
                        onPressed: () =>
                            context.read<InvoiceFormCubit>().save(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final current = context.read<InvoiceFormCubit>().state;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.date,
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
      context.read<InvoiceFormCubit>().dateChanged(picked);
    }
  }

  Future<void> _pickDueDate() async {
    final current = context.read<InvoiceFormCubit>().state;
    final picked = await showDatePicker(
      context: context,
      initialDate:
          current.dueDate ?? current.date.add(const Duration(days: 30)),
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
      context.read<InvoiceFormCubit>().dueDateChanged(picked);
    }
  }
}
