import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/theme/app_text_styles.dart';
import 'package:inveio/expenses/presentation/widgets/expense_category_row.dart';
import 'package:inveio/expenses/presentation/widgets/expense_input_fields.dart';
import 'package:inveio/expenses/presentation/widgets/expense_gst_display.dart';
import 'package:inveio/expenses/presentation/widgets/expense_payment_mode_selector.dart';
import 'package:inveio/expenses/presentation/widgets/expense_receipt_button.dart';
import 'package:inveio/expenses/domain/entities/expense_prefill.dart';
import 'package:inveio/expenses/presentation/cubit/expense_form_cubit.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:inveio/shared/presentation/widgets/scan_low_confidence.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Screen for adding a new expense, or editing an existing one.
///
/// Passing [expenseId] switches the screen into edit mode: the transaction is
/// loaded through `ExpenseFormCubit.loadForEdit` and the saved GST values are
/// restored as-is. Passing [scannedData] prefills a new expense from a scan.
/// The two are mutually exclusive.
class ExpenseFormScreen extends StatefulWidget {
  final ParsedReceipt? scannedData;

  /// Local path of a scanned/picked receipt image to attach to this expense.
  final String? scannedImagePath;

  /// Local ID of the expense to edit. `null` means "add a new expense".
  final String? expenseId;

  const ExpenseFormScreen({
    super.key,
    this.scannedData,
    this.scannedImagePath,
    this.expenseId,
  }) : assert(
         expenseId == null || scannedData == null,
         'Cannot edit an expense and prefill it from a scan at the same time.',
       );

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _gstinController;
  late final TextEditingController _vendorNameController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    _gstinController = TextEditingController();
    _vendorNameController = TextEditingController();

    final scanned = widget.scannedData;
    final expenseId = widget.expenseId;
    if (expenseId != null) {
      context.read<ExpenseFormCubit>().loadForEdit(expenseId);
    } else if (scanned != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ExpenseFormCubit>().populateFromScan(
          ExpensePrefill(
            amount: scanned.amount.value,
            gstin: scanned.gstin.value,
            vendorName: scanned.vendor.value,
            transactionDate: scanned.date.value,
          ),
        );
      });
    }

    final imagePath = widget.scannedImagePath;
    if (imagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<ExpenseFormCubit>().receiptAttached(imagePath);
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _gstinController.dispose();
    _vendorNameController.dispose();
    super.dispose();
  }

  /// Syncs the text controllers from cubit state (used for scan prefill).
  ///
  /// Only writes when the value actually differs so the user's cursor/typing is
  /// never clobbered.
  void _syncFromState(ExpenseFormState state) {
    final amountText = _amountController.text;
    if ((double.tryParse(amountText) ?? 0.0) != state.amount) {
      _setControllerText(
        _amountController,
        state.amount == 0.0 ? '' : _formatAmount(state.amount),
      );
    }
    _setControllerText(_descriptionController, state.description);
    _setControllerText(_gstinController, state.counterpartyGstin);
    _setControllerText(_vendorNameController, state.vendorName ?? '');
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
    final scanned = widget.scannedData;
    final lowConfAmount = scanned != null && !scanned.amount.isHighConfidence;
    final lowConfGstin = scanned != null && !scanned.gstin.isHighConfidence;
    final lowConfVendor = scanned != null && !scanned.vendor.isHighConfidence;
    final isEditing = widget.expenseId != null;

    return BlocListener<ExpenseFormCubit, ExpenseFormState>(
      listenWhen: (previous, current) =>
          previous.saveSuccess != current.saveSuccess ||
          previous.saveError != current.saveError,
      listener: (context, state) {
        if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Expense updated' : 'Expense saved'),
            ),
          );
          context.read<TransactionBloc>().add(
            const LatestTransactionsRequested(),
          );
          if (context.mounted && context.canPop()) context.pop();
        } else if (state.saveError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.saveError!)));
        }
      },
      child: BlocListener<ExpenseFormCubit, ExpenseFormState>(
        listenWhen: (previous, current) =>
            previous.amount != current.amount ||
            previous.description != current.description ||
            previous.counterpartyGstin != current.counterpartyGstin ||
            previous.vendorName != current.vendorName,
        listener: (context, state) => _syncFromState(state),
        child: BlocBuilder<ExpenseFormCubit, ExpenseFormState>(
          builder: (context, state) {
            return Scaffold(
              body: SafeArea(
                minimum: const EdgeInsets.all(6),
                child: CustomScrollView(
                  slivers: [
                    AppBarWidget(
                      title: isEditing ? 'Edit expense' : 'New expense',
                    ),
                    if (state.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (state.notFound)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _NotFoundView(
                          onBack: () {
                            if (context.canPop()) context.pop();
                          },
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                        hintStyle: AppTextStyles.monoLarge
                                            .copyWith(
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
                                        .read<ExpenseFormCubit>()
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
                              const SizedBox(height: 20),
                              const ExpenseFieldLabel('Category'),
                              const SizedBox(height: 10),
                              ExpenseCategoryRow(
                                selectedCategory: state.category,
                                onCategorySelected: (cat) => context
                                    .read<ExpenseFormCubit>()
                                    .categorySelected(cat),
                              ),
                              const SizedBox(height: 15),
                              const ExpenseFieldLabel('Date'),
                              const SizedBox(height: 8),
                              ExpenseDateField(
                                date: state.date,
                                time: state.time,
                                onTap: _pickDate,
                                timePicker: _pickTime,
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
                              const SizedBox(height: 16),
                              const ExpenseFieldLabel('Description'),
                              const SizedBox(height: 8),
                              TextFieldWidget(
                                controller: _descriptionController,
                                hintText: 'What was this for?',
                                textStyle: const TextStyle(
                                  color: AppColors.darkTextPrimary,
                                ),
                                cursorColor: AppColors.primary,
                                decoration: expenseInputDecoration(
                                  hint: 'What was this for?',
                                ),
                                onChanged: (value) => context
                                    .read<ExpenseFormCubit>()
                                    .descriptionChanged(value),
                              ),
                              const SizedBox(height: 16),
                              const ExpenseFieldLabel('Seller GSTIN'),
                              const SizedBox(height: 8),
                              TextFieldWidget(
                                controller: _gstinController,
                                hintText: 'GSTIN (optional)',
                                maxLength: 15,
                                textCapitalization:
                                    TextCapitalization.characters,
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
                                    .read<ExpenseFormCubit>()
                                    .gstinChanged(value),
                              ),
                              const SizedBox(height: 8),
                              const ExpenseFieldLabel('GST Rate'),
                              const SizedBox(height: 8),
                              _GstRatePicker(
                                selectedRate: state.gstSlab,
                                onRateSelected: (rate) => context
                                    .read<ExpenseFormCubit>()
                                    .gstRateChanged(rate),
                              ),
                              if (state.isGstRateDefault) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'GST rate not found on the receipt. '
                                  '${state.gstSlab}% is used by default.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              ExpenseGstDisplay(
                                cgst: state.gst.cgst,
                                sgst: state.gst.sgst,
                                igst: state.gst.igst,
                                taxableAmount: state.gst.taxableAmount,
                                isInterState: state.gst.isInterState,
                              ),

                              const SizedBox(height: 16),
                              const ExpenseFieldLabel('Vendor'),
                              const SizedBox(height: 8),
                              TextFieldWidget(
                                controller: _vendorNameController,
                                hintText: 'Vendor name',
                                textStyle: const TextStyle(
                                  color: AppColors.darkTextPrimary,
                                ),
                                cursorColor: AppColors.primary,
                                decoration: applyScanLowConfidence(
                                  expenseInputDecoration(hint: 'Vendor name'),
                                  lowConfidence: lowConfVendor,
                                ),
                                onChanged: (value) => context
                                    .read<ExpenseFormCubit>()
                                    .vendorNameChanged(value),
                              ),
                              const SizedBox(height: 16),
                              const ExpenseFieldLabel('Payment Mode'),
                              const SizedBox(height: 8),
                              ExpensePaymentModeSelector(
                                selectedMode: state.paymentMode,
                                onModeSelected: (mode) => context
                                    .read<ExpenseFormCubit>()
                                    .paymentModeSelected(mode),
                              ),
                              if (state.showCashWarning) ...[
                                const SizedBox(height: 12),
                                const ExpenseCashWarning(),
                              ],
                              const SizedBox(height: 16),
                              ExpenseItcToggle(
                                value: state.itcEligible ?? false,
                                onChanged: (value) => context
                                    .read<ExpenseFormCubit>()
                                    .itcEligibleToggled(value),
                              ),
                              const SizedBox(height: 8),
                              ExpenseReceiptButton(
                                receiptPath: state.receiptPath,
                                onPressed: _attachReceipt,
                                onRemove: _removeReceipt,
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              bottomNavigationBar: state.isLoading || state.notFound
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(
                        bottom: 40,
                        top: 10,
                        right: 16,
                        left: 16,
                      ),
                      child: NeonButton(
                        label: isEditing ? 'Save changes' : 'Save expense',
                        borderRadius: BorderRadius.circular(100),
                        onPressed: () =>
                            context.read<ExpenseFormCubit>().save(),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final current = context.read<ExpenseFormCubit>().state;
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
      context.read<ExpenseFormCubit>().dateChanged(date: picked);
    }
  }

  Future<void> _pickTime() async {
    final current = context.read<ExpenseFormCubit>().state;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current.date ?? DateTime.now()),
    );
    if (picked != null && mounted) {
      context.read<ExpenseFormCubit>().dateChanged(time: picked);
    }
  }

  void _attachReceipt() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    context.read<ExpenseFormCubit>().receiptAttached(picked.path);
  }

  void _removeReceipt() {
    context.read<ExpenseFormCubit>().receiptRemoved();
  }
}

/// A pill-style selector for the GST rate (0/5/12/18/28).
class _GstRatePicker extends StatelessWidget {
  final int selectedRate;
  final ValueChanged<int> onRateSelected;

  const _GstRatePicker({
    required this.selectedRate,
    required this.onRateSelected,
  });

  static const _rates = [0, 5, 12, 18, 28];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final rate in _rates)
          GestureDetector(
            onTap: () => onRateSelected(rate),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: rate == selectedRate
                    ? AppColors.primary
                    : AppColors.darkInput,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: rate == selectedRate
                      ? AppColors.primary
                      : AppColors.darkBorder,
                ),
              ),
              child: Text(
                '$rate%',
                style: TextStyle(
                  color: rate == selectedRate
                      ? Colors.black
                      : AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Shown when the id in the edit route does not resolve to a transaction.
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
              'Expense not found',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.darkTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This expense may have been deleted.',
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
