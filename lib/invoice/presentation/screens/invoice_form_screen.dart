import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/presentation/widgets/scan_low_confidence.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/theme/app_text_styles.dart';
import 'package:inveio/expenses/presentation/widgets/expense_input_fields.dart';
import 'package:inveio/invoice/presentation/widgets/add_invoice_form_fields.dart';
import 'package:inveio/invoice/presentation/widgets/invoice_gst_display.dart';
import 'package:inveio/invoice/presentation/widgets/invoice_save_button.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:inveio/invoice/presentation/cubit/invoice_form_cubit.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Screen for adding a new invoice, or editing an existing one.
///
/// Passing [invoiceId] switches the screen into edit mode, where the invoice is
/// loaded through `InvoiceFormCubit.loadForEdit`. Passing [scannedData] prefills
/// a new invoice from a scan. The two are mutually exclusive.
class InvoiceFormScreen extends StatefulWidget {
  final ParsedReceipt? scannedData;

  /// Local path of the scanned receipt image to attach to this invoice.
  final String? scannedImagePath;

  /// Local ID of the invoice to edit. `null` means "add a new invoice".
  final String? invoiceId;

  const InvoiceFormScreen({
    super.key,
    this.scannedData,
    this.scannedImagePath,
    this.invoiceId,
  }) : assert(
          invoiceId == null || scannedData == null,
          'Cannot edit an invoice and prefill it from a scan at the same time.',
        );

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
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

    final scannedData = widget.scannedData;
    final invoiceId = widget.invoiceId;
    if (invoiceId != null) {
      context.read<InvoiceFormCubit>().loadForEdit(invoiceId);
    } else if (scannedData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<InvoiceFormCubit>().populateFromScan(scannedData);
      });
    }

    final imagePath = widget.scannedImagePath;
    if (imagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<InvoiceFormCubit>().receiptAttached(imagePath);
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
        state.amount == 0.0 ? '' : _formatAmount(state.amount),
      );
    }
    _setControllerText(_descriptionController, state.description);
    _setControllerText(_gstinController, state.clientGstin);
    _setControllerText(_clientNameController, state.clientName ?? '');
    _setControllerText(_invoiceNumberController, state.invoiceNumber ?? '');
  }

  String _formatAmount(double amount) {
    if (amount == amount.floor()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(2);
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
    final isEditing = widget.invoiceId != null;
    final scanned = widget.scannedData;
    final lowConfAmount = scanned != null && !scanned.amount.isHighConfidence;
    final lowConfDate = scanned != null && !scanned.date.isHighConfidence;
    final lowConfVendor = scanned != null && !scanned.vendor.isHighConfidence;
    final lowConfGstin = scanned != null && !scanned.gstin.isHighConfidence;
    return BlocListener<InvoiceFormCubit, InvoiceFormState>(
      listenWhen: (previous, current) =>
          previous.saveSuccess != current.saveSuccess ||
          previous.saveError != current.saveError,
      listener: (context, state) {
        if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Invoice updated' : 'Invoice saved'),
            ),
          );
          context.read<TransactionBloc>().add(
            const LatestTransactionsRequested(),
          );
          context.read<TransactionBloc>().add(const AllInvoicesRequested());
          if (context.mounted && context.canPop()) context.pop();
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
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.notFound
                    ? _NotFoundView(
                        onBack: () {
                          if (context.canPop()) context.pop();
                        },
                      )
                    : SingleChildScrollView(
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
                                    decoration: applyScanLowConfidence(
                                      InputDecoration(
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
                                          color: AppColors.primary.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                      lowConfidence: lowConfAmount,
                                      lowConfidenceText: false,
                                    ),
                                    onChanged: (value) => context
                                        .read<InvoiceFormCubit>()
                                        .amountChanged(value),
                                  ),
                                ),
                              ),
                              scanLowConfidenceHint(
                                lowConfidence: lowConfAmount,
                              ),
                              if (state.amountError != null) ...[
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  state.amountError!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            const InvoiceFieldLabel('Date'),
                            const SizedBox(height: 8),
                            InvoiceDateField(
                              date: state.date,
                              onTap: _pickDate,
                            ),
                            if (state.date == null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Date not found, please set it',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                            scanLowConfidenceHint(
                              lowConfidence: lowConfDate,
                            ),
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
                              decoration: applyScanLowConfidence(
                                expenseInputDecoration(
                                  hint: 'Client name',
                                ),
                                lowConfidence: lowConfVendor,
                              ),
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
                              decoration: expenseInputDecoration(
                                hint: 'INV-001',
                              ),
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
                              decoration: applyScanLowConfidence(
                                expenseInputDecoration(
                                  hint: 'GSTIN (optional)',
                                ),
                                lowConfidence: lowConfGstin,
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
                              label: isEditing
                                  ? 'Save changes'
                                  : 'Save invoice',
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
      initialDate: current.date ?? DateTime.now(),
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
          current.dueDate ??
          (current.date ?? DateTime.now()).add(const Duration(days: 30)),
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

/// Shown when the id in the edit route does not resolve to an invoice.
class _NotFoundView extends StatelessWidget {
  final VoidCallback onBack;

  const _NotFoundView({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.darkTextMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'Invoice not found',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This invoice may have been deleted.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.darkTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            NeonButton(
              label: 'Go back',
              borderRadius: BorderRadius.circular(100),
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}
