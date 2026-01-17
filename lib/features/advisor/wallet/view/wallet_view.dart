import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/balance_card.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:tayseer/my_import.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletCubit()..loadAllTransactions(),
      child: DefaultTabController(
        length: 2,
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
                      Gap(16.h),
                      SimpleAppBar(title: 'محفظتى'),
                      SizedBox(height: 20.h),
                      const CustomToggleTabBar(
                        firstTabText: 'محفظتي',
                        secondTabText: 'سجل الدفع',
                      ),
                      SizedBox(height: 10.h),
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
                  'سجل المعاملات',
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
                    'عرض الكل',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.primary400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Transactions List
          if (state.status == WalletStatus.loading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              child: const CircularProgressIndicator(),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) =>
                  TransactionItem(transaction: transactions[index]),
            ),
          SizedBox(height: 20.h),

          // Withdrawal Button
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
            child: CustomBotton(
              title: 'سحب',
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.kWithdrawalView);
              },
              useGradient: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRecord(BuildContext context, WalletState state) {
    final transactions = state.bookingTransactions.take(6).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Transactions Header
          Padding(
            padding: EdgeInsets.only(right: 25.w, left: 8.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل الحجوزات',
                  style: Styles.textStyle20Bold.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.kBookingsLogView);
                  },
                  child: Text(
                    'عرض الكل',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.primary400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Transactions List
          if (state.status == WalletStatus.loading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 50.h),
              child: const CircularProgressIndicator(),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) =>
                  TransactionItem(transaction: transactions[index]),
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
