import 'package:inveio/invoice/domain/services/invoice_pdf_generator.dart';
import 'package:inveio/invoice/presentation/cubit/invoice_pdf_cubit.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:inveio/settings/presentation/cubit/export_data_cubit.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/dependencies/app_dependencies.dart';
import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/presentation/widgets/transaction_card_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late final ExportDataCubit _exportCubit;
  late final InvoicePdfCubit _pdfCubit;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const AllInvoicesRequested());
    _exportCubit = AppDependencies.sl<ExportDataCubit>();
    _pdfCubit = InvoicePdfCubit(
      onboardingRepository: AppDependencies.sl<OnboardingRepository>(),
      generator: AppDependencies.sl<InvoicePdfGenerator>(),
      uid: FirebaseAuth.instance.currentUser?.uid ?? '',
    );
  }

  @override
  void dispose() {
    _exportCubit.close();
    _pdfCubit.close();
    super.dispose();
  }

  /// Exports invoice data and opens the share sheet with the CSV file.
  Future<void> _downloadInvoices() async {
    await _exportCubit.exportInvoices();
    if (!mounted) return;

    final state = _exportCubit.state;
    if (state is ExportDataSuccess) {
      await _shareExportedFile(state.filePath);
    } else if (state is ExportDataFailure) {
      _showSnack(state.message);
    }
  }

  Future<void> _shareExportedFile(String path) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'text/csv')],
        subject: 'Invoices',
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Builds the PDF via [InvoicePdfCubit] and shares it.
  Future<void> _shareInvoicePdf(TransactionEntity invoice) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final bytes = await _pdfCubit.build(invoice);
    if (!mounted) return;
    Navigator.pop(context);
    if (bytes == null) {
      _showSnack(_pdfCubit.state.error ?? 'Failed to generate PDF.');
      return;
    }
    final filename = _pdfCubit.state.filename ?? 'invoice.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  /// Builds the PDF via [InvoicePdfCubit] and opens the print dialog.
  Future<void> _printInvoicePdf(TransactionEntity invoice) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final bytes = await _pdfCubit.build(invoice);
    if (!mounted) return;
    Navigator.pop(context);
    if (bytes == null) {
      _showSnack(_pdfCubit.state.error ?? 'Failed to generate PDF.');
      return;
    }
    await Printing.layoutPdf(
      name: _pdfCubit.state.filename ?? 'invoice.pdf',
      onLayout: (_) async => bytes,
    );
  }

  void _handleMenuAction(TransactionMenuAction action, TransactionEntity invoice) {
    switch (action) {
      case TransactionMenuAction.sharePdf:
        _shareInvoicePdf(invoice);
      case TransactionMenuAction.print:
        _printInvoicePdf(invoice);
      case TransactionMenuAction.edit:
      case TransactionMenuAction.details:
      case TransactionMenuAction.duplicate:
      case TransactionMenuAction.share:
      case TransactionMenuAction.delete:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          AppBarWidget(
            title: 'Invoices',
            subTitle: 'Create and manage your invoices',
            subTitleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Theme.of(context).hintColor,
            ),
            titleStyle: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            actions: [
              PopupMenuButton<String>(
                color: AppColors.darkCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                tooltip: 'Invoice options',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                ),
                icon: const Icon(LucideIcons.moreVertical, size: 18),
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(LucideIcons.download, size: 18),
                        SizedBox(width: 12),
                        Text('Download'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'download') _downloadInvoices();
                },
              ),
            ],
          ),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state.invoices.isLoadingInvoices) {
                return const Center(
                  child: CircularProgressIndicator(),
                ).toSliver();
              }

              if (state.invoices.invoicesError != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      state.invoices.invoicesError!,
                      style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).toSliver();
              }

              if (state.invoices.invoices.isEmpty) {
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AppConstants.folderPaperPlaneIllustration,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 150,
                        ),

                        const SizedBox(height: 16),
                        const Text(
                          'No invoices yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ).withPadding(const EdgeInsets.only(bottom: 10)),
                        const Text(
                          'Create your first invoice to get started. \n Send to clients, track payments, and keep everything in one place.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        NeonButton(
                          label: 'Create Invoice',
                          icon: LucideIcons.plus,
                          onPressed: () =>
                              context.pushNamed(RouterConstants.addInvoice),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const InvoiceInfoCard(
                              icon: LucideIcons.fileText,
                              title: 'Professional invoices',
                              subTitle: 'Look professional in seconds',
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              color: Theme.of(context).focusColor.withAlpha(9),
                            ),
                            const InvoiceInfoCard(
                              icon: LucideIcons.send,
                              title: 'Easy sharing',
                              subTitle: 'Send via link email',
                            ),
                            Container(
                              width: 1,
                              height: 50,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              color: Theme.of(context).focusColor.withAlpha(9),
                            ),
                            const InvoiceInfoCard(
                              icon: LucideIcons.circleDollarSign,
                              title: 'Track payments',
                              subTitle: 'Stay on top of your business',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).toSliver();
              }

              return SliverList.builder(
                itemCount: state.invoices.invoices.length,
                itemBuilder: (context, index) {
                  final invoice = state.invoices.invoices[index];
                  final gstLabel = invoice.isInterState ? 'IGST' : 'CGST+SGST';
                  final dateStr = DateFormat(
                    'MMM d, yyyy',
                  ).format(invoice.date);
                  final gstAmount = invoice.cgst + invoice.sgst + invoice.igst;

                  void openDetails() {
                    final localId = invoice.localId;
                    if (localId == null) return;
                    context.pushNamed(
                      RouterConstants.transactionDetails,
                      extra: localId,
                    );
                  }

                  void editInvoice() {
                    final localId = invoice.localId;
                    if (localId == null) return;
                    context.pushNamed(
                      RouterConstants.editInvoice,
                      pathParameters: {'id': localId.toString()},
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TransactionCardWidget(
                      transactionUid: invoice.uid,
                      transactionLocalId: invoice.localId,
                      title:
                          invoice.clientName ??
                          invoice.invoiceNumber ??
                          'Invoice',
                      subTitle: dateStr,
                      subTitleTrailing: AccentChip(
                        label: gstLabel,
                        compact: true,
                        selected: invoice.isInterState,
                      ),
                      icon: LucideIcons.fileText,
                      iconColor: AppColors.primary,
                      mainAmount: invoice.totalAmount,
                      subAmount: gstAmount,
                      subAmountPrefix: 'GST: ',
                      amountFractionDigits: 2,
                      onTap: openDetails,
                      onEdit: editInvoice,
                      invoiceActions: true,
                      onMenuAction: (action) =>
                          _handleMenuAction(action, invoice),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class InvoiceInfoCard extends StatelessWidget {
  final String title, subTitle;
  final IconData icon;
  const InvoiceInfoCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).cardColor,
            ),
            child: Icon(icon, size: 17, color: Theme.of(context).hintColor),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}
