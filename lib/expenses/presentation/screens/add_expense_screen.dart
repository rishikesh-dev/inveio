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
import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

/// Screen for adding a new expense transaction.
class AddExpenseScreen extends StatefulWidget {
  final ScannedReceiptEntity? scannedData;

  /// Local path of a scanned/picked receipt image to attach to this expense.
  final String? scannedImagePath;

  const AddExpenseScreen({super.key, this.scannedData, this.scannedImagePath});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _gstinController;
  late final TextEditingController _vendorNameController;

  @override
  void initState() {
    super.initState();
    debugPrint(
      'Initializing AddExpenseScreen with scannedData: ${widget.scannedData}',
    );
    debugPrint(
      'amount: ${widget.scannedData?.amount}, description: ${widget.scannedData?.rawText}, gstin: ${widget.scannedData?.gstin}, vendorName: ${widget.scannedData?.vendorName}',
    );
    _amountController = TextEditingController(
      text: widget.scannedData?.amount?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.scannedData?.vendorName != null
          ? 'Purchase from ${widget.scannedData!.vendorName}'
          : '',
    );
    _gstinController = TextEditingController(text: widget.scannedData?.gstin);
    _vendorNameController = TextEditingController(
      text: widget.scannedData?.vendorName,
    );

    if (widget.scannedData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransactionBloc>().add(
          PopulateFromScan(widget.scannedData!),
        );
      });
    } else {
      context.read<TransactionBloc>().add(const ResetForm());
    }

    final imagePath = widget.scannedImagePath;
    if (imagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<TransactionBloc>().add(ReceiptAttached(imagePath));
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

  InputDecoration _applyWarning(
    InputDecoration base, {
    required bool lowConfidence,
    bool lowConfidenceText = true,
  }) {
    if (!lowConfidence) return base;
    return base.copyWith(
      suffixIcon: const Icon(
        Icons.warning_amber_outlined,
        color: AppColors.warning,
      ),
      helperText: lowConfidenceText ? 'Please verify this value' : null,
      helperStyle: const TextStyle(color: AppColors.warning, fontSize: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lowConfAmount = widget.scannedData?.confidence.amount == false;
    final lowConfGstin = widget.scannedData?.confidence.gstin == false;
    final lowConfVendor = widget.scannedData?.confidence.vendorName == false;

    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state.save.saveSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Expense saved')));
          if (context.mounted && context.canPop()) context.pop();
        } else if (state.save.saveError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.save.saveError!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                const AppBarWidget(),
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
                              decoration: _applyWarning(
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
                                  .read<TransactionBloc>()
                                  .add(AmountChanged(value)),
                            ),
                          ),
                        ),
                        if (lowConfAmount) ...[
                          Center(
                            child: Text(
                              'Please verify this value',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        const ExpenseFieldLabel('Category'),
                        const SizedBox(height: 10),
                        ExpenseCategoryRow(
                          selectedCategory: state.form.category,
                          onCategorySelected: (cat) => context
                              .read<TransactionBloc>()
                              .add(CategorySelected(cat)),
                        ),
                        const SizedBox(height: 15),
                        const ExpenseFieldLabel('Date'),
                        const SizedBox(height: 8),
                        ExpenseDateField(
                          date: state.form.date,
                          time: state.form.time,
                          onTap: _pickDate,
                          timePicker: _pickTime,
                        ),
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
                              .read<TransactionBloc>()
                              .add(DescriptionChanged(value)),
                        ),
                        const SizedBox(height: 16),
                        const ExpenseFieldLabel('Seller GSTIN'),
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
                          decoration: _applyWarning(
                            expenseInputDecoration(hint: 'GSTIN (optional)'),
                            lowConfidence: lowConfGstin,
                          ),
                          onChanged: (value) => context
                              .read<TransactionBloc>()
                              .add(GstinChanged(value)),
                        ),
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
                          decoration: _applyWarning(
                            expenseInputDecoration(hint: 'Vendor name'),
                            lowConfidence: lowConfVendor,
                          ),
                          onChanged: (value) => context
                              .read<TransactionBloc>()
                              .add(VendorNameChanged(value)),
                        ),
                        const SizedBox(height: 16),
                        const ExpenseFieldLabel('Payment Mode'),
                        const SizedBox(height: 8),
                        ExpensePaymentModeSelector(
                          selectedMode: state.form.paymentMode,
                          onModeSelected: (mode) => context
                              .read<TransactionBloc>()
                              .add(PaymentModeSelected(mode)),
                        ),
                        if (state.showCashWarning) ...[
                          const SizedBox(height: 12),
                          const ExpenseCashWarning(),
                        ],
                        const SizedBox(height: 16),
                        ExpenseItcToggle(
                          value: state.form.itcEligible ?? false,
                          onChanged: (value) => context
                              .read<TransactionBloc>()
                              .add(ItcEligibleToggled(value)),
                        ),
                        const SizedBox(height: 8),
                        ExpenseReceiptButton(
                          receiptPath: state.form.receiptPath,
                          onPressed: _attachReceipt,
                          onRemove: _removeReceipt,
                        ),
                        const SizedBox(height: 32),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(
              bottom: 40,
              top: 15,
              right: 16,
              left: 16,
            ),
            child: NeonButton(
              label: 'Save expense',
              borderRadius: BorderRadius.circular(100),
              // isSaving: state.save.isSaving,
              onPressed: () => context.read<TransactionBloc>().add(
                const UpsertTransaction(),
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

  Future<void> _pickTime() async {
    final current = context.read<TransactionBloc>().state;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current.form.date),
    );
    if (picked != null && mounted) {
      context.read<TransactionBloc>().add(DateChanged(time: picked));
    }
  }

  void _attachReceipt() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    context.read<TransactionBloc>().add(ReceiptAttached(picked.path));
  }

  void _removeReceipt() {
    context.read<TransactionBloc>().add(const ReceiptRemoved());
  }
}
