import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/balance_card.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WalletCubit>()..loadAllData(),
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          backgroundColor: AppColors.kScaffoldColor,
          body: AdvisorBackground(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 105.h,
                  child: Image.asset(
                    AssetsData.homeBarBackgroundImage,
                    fit: BoxFit.fill,
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Gap(16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: SimpleAppBar(title: context.tr('my_wallet')),
                      ),

                      // ── نفس ستايل الـ TabBar الموجود في ArchiveView ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                          padding: EdgeInsets.all(2.5.w),
                          decoration: BoxDecoration(
                            color: AppColors.tabsBack,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(color: AppColors.primary100),
                          ),
                          child: Builder(
                            builder: (context) {
                              final bool isTablet =
                                  MediaQuery.of(context).size.width > 600;
                              return TabBar(
                                indicatorSize: TabBarIndicatorSize.tab,
                                dividerColor: Colors.transparent,
                                indicator: BoxDecoration(
                                  color: AppColors.primary300,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                labelStyle: isTablet
                                    ? Styles.textStyle16
                                    : Styles.textStyle20,
                                labelPadding: isTablet
                                    ? EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                        vertical: 12.h,
                                      )
                                    : EdgeInsets.zero,
                                labelColor: AppColors.secondary950,
                                unselectedLabelColor: AppColors.blackColor,
                                unselectedLabelStyle: Styles.textStyle16,
                                tabs: [
                                  Tab(text: context.tr('my_wallet')),
                                  Tab(text: context.tr('payment_record')),
                                ],
                              );
                            },
                          ),
                        ),
                      ),

                      // المحتوى
                      Expanded(
                        child: BlocBuilder<WalletCubit, WalletState>(
                          builder: (context, state) {
                            return TabBarView(
                              children: [
                                _buildWalletContent(context, state),
                                _buildPaymentRecord(context, state),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletContent(BuildContext context, WalletState state) {
    final transactions = state.walletTransactions.take(6).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Balance Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: const BalanceCard(),
          ),
          SizedBox(height: 20.h),

          // Transactions Header
          Padding(
            padding: EdgeInsets.only(right: 25.w, left: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('transactions_log'),
                  style: Styles.textStyle20Bold.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.kTransactionsLogView,
                    );
                  },
                  child: Text(
                    context.tr('view_all'),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.primary400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Skeletonizer(
            enabled: state.status == WalletStatus.loading,
            child: transactions.isEmpty && state.status != WalletStatus.loading
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      context.tr('no_transactions'),
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.secondary600,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.status == WalletStatus.loading
                        ? 5
                        : transactions.length,
                    itemBuilder: (context, index) => TransactionItem(
                      transaction: state.status == WalletStatus.loading
                          ? TransactionModel(
                              id: '',
                              amount: 0,
                              displayAmount: '+000',
                              type: 'session',
                              eventTicketsNumber: 0,
                              formattedDate: '24 ديسمبر 2025',
                            )
                          : transactions[index],
                    ),
                  ),
          ),

          SizedBox(height: 20.h),

          // Withdrawal Button
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
            child: CustomBotton(
              height: 54.h,
              width: double.infinity,
              title: context.tr('withdraw'),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.kWithdrawalView);
              },
              useGradient: true,
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildPaymentRecord(BuildContext context, WalletState state) {
    final transactions = state.bookingTransactions.take(6).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(right: 25.w, left: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('bookings_log'),
                  style: Styles.textStyle20Bold.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.kBookingsLogView);
                  },
                  child: Text(
                    context.tr('view_all'),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.primary400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transactions List
          Skeletonizer(
            enabled: state.status == WalletStatus.loading,
            child: transactions.isEmpty && state.status != WalletStatus.loading
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      context.tr('no_bookings'),
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.secondary600,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.status == WalletStatus.loading
                        ? 5
                        : transactions.length,
                    itemBuilder: (context, index) => TransactionItem(
                      transaction: state.status == WalletStatus.loading
                          ? TransactionModel(
                              id: '',
                              amount: 0,
                              displayAmount: '+000',
                              type: 'event',
                              eventTicketsNumber: 0,
                              formattedDate: '24 ديسمبر 2025',
                            )
                          : transactions[index],
                    ),
                  ),
          ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
