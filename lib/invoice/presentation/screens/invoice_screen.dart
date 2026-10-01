import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/presentation/widgets/accent_chip.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const AllTransactionsRequested());
    tabController = TabController(length: 4, vsync: this);
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
              IconButton.filled(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                ),
                icon: const Icon(LucideIcons.search, size: 18),
              ),
              IconButton.filled(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                ),
                icon: const Icon(LucideIcons.moreVertical, size: 18),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TabBar(
                splashBorderRadius: BorderRadius.circular(100),
                indicatorAnimation: TabIndicatorAnimation.elastic,
                dividerHeight: 0,
                unselectedLabelColor: Theme.of(context).hintColor,
                indicatorWeight: 1,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsetsGeometry.symmetric(
                  horizontal: 0,
                  vertical: 1,
                ),
                indicatorColor: Theme.of(context).cardColor,
                indicator: BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(60),
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(100),
                ),
                controller: tabController,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Paid'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Overdue'),
                ],
              ),
            ),
          ),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state.latest.isLoadingLatest) {
                return const Center(
                  child: CircularProgressIndicator(),
                ).toSliver();
              }

              if (state.latest.latestError != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      state.latest.latestError!,
                      style: const TextStyle(
                        color: AppColors.darkTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ).toSliver();
              }

              if (state.latest.latestExpenses.isEmpty) {
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
                              subTitle: 'Send via link email or PDF',
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
                itemCount: state.latest.latestExpenses.length,
                itemBuilder: (context, index) {
                  final invoice = state.latest.latestExpenses[index];
                  return _InvoiceCard(invoice: invoice);
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

class _InvoiceCard extends StatelessWidget {
  final TransactionEntity invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final gstLabel = invoice.isInterState ? 'IGST' : 'CGST+SGST';
    final dateStr = DateFormat('MMM d, yyyy').format(invoice.date);
    final displayName =
        invoice.clientName ?? invoice.invoiceNumber ?? 'Invoice';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(RouterConstants.editInvoice, extra: invoice);
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).focusColor,
                ),
                child: const Icon(
                  LucideIcons.fileText,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AccentChip(
                          label: gstLabel,
                          compact: true,
                          selected: invoice.isInterState,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    invoice.totalAmount.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'GST: ${(invoice.cgst + invoice.sgst + invoice.igst).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
