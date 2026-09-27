import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/scan/presentation/cubit/receipt_scanner_cubit.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/home/presentation/widgets/quick_action_widget.dart';
import 'package:inveio/shared/presentation/widgets/section_title_row.dart';
import 'package:inveio/shared/presentation/widgets/transaction_card_widget.dart';
import 'package:inveio/shared/presentation/widgets/user_avatar_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/utils/greeting.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:inveio/home/presentation/widgets/dashboard_spend_summary_card.dart';
import 'package:inveio/shared/presentation/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The main home screen of the app, displaying a greeting, quick actions,
/// recent transactions, and a dashboard summary for the signed-in user.
class HomeScreen extends StatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionBloc>().add(
          const LatestTransactionsRequested(limit: 10),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        minimum: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! AuthSignedIn) {
              return const Center(child: Text('Home'));
            }
            return CustomScrollView(
              slivers: [
                AppBarWidget(
                  title: '$greeting,',
                  subTitle: state.user.name,

                  titleStyle: const TextStyle(fontSize: 16),
                  subTitleStyle: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  actions: [
                    UserAvatarWidget(userName: state.user.name),
                    const SizedBox(width: 10.0),
                  ],
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10.0)),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DashboardSpendSummaryCard().toAnimatedEntrance(
                            delay: const Duration(milliseconds: 70),
                          ),
                          const SizedBox(height: 22),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                QuickActionWidget(
                                  icon: LucideIcons.scanText,
                                  bgColor: AppColors.primary,
                                  iconColor: AppColors.primaryDark,
                                  onTap: () {
                                    context
                                        .read<ReceiptScannerCubit>()
                                        .scanReceipt();
                                  },
                                  title: 'Scan',
                                ),
                                QuickActionWidget(
                                  icon: LucideIcons.plusCircle,
                                  title: 'Manual',
                                  onTap: () {
                                    context.pushNamed(
                                      RouterConstants.addExpense,
                                    );
                                  },
                                ),
                                QuickActionWidget(
                                  icon: LucideIcons.chartArea,
                                  title: 'Insights',
                                  onTap: () {
                                    indexBottomNotifier.value = 2;
                                  },
                                ),
                                QuickActionWidget(
                                  icon: LucideIcons.banknote,
                                  title: 'Transfer',
                                  onTap: () {
                                    indexBottomNotifier.value = 2;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: SectionTitleRow(
                    title: 'Recent Transactions',
                    action: 'View All',
                    onActionTap: () {
                      indexBottomNotifier.value = 1;
                    },
                  ),
                ),
                BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    if (state.latest.isLoadingLatest) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (state.latest.latestError != null) {
                      debugPrint(
                        'Transaction load error: ${state.latest.latestError}',
                      );
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(state.latest.latestError!),
                        ),
                      );
                    }

                    if (state.latest.latestExpenses.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 240,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                spacing: 5,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No expenses yet',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily:
                                          AppConstants.primaryFontFamily,
                                    ),
                                  ),
                                  Text(
                                    'Every expense you log gets GST-split automatically — no manual math.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      fontFamily:
                                          AppConstants.primaryFontFamily,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverList.builder(
                      itemCount: state.latest.latestExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = state.latest.latestExpenses[index];
                        return TransactionCardWidget(
                          title:
                              expense.vendorName ??
                              expense.category ??
                              expense.description,
                          onTap: () => context.pushNamed(
                            RouterConstants.transactionDetails,
                            extra: expense.id,
                          ),
                          icon: Icons.currency_rupee_sharp,
                          subTitle:
                              '${DateFormat('MMM d').format(expense.date)}'
                              ' - ${expense.category ?? 'Expense'}',
                          mainAmount: expense.totalAmount,
                          subAmount: expense.cgst + expense.sgst + expense.igst,
                        );
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
