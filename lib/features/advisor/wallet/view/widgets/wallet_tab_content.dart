import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/balance_card.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/wallet_empty_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/wallet_section_header.dart';
import 'package:tayseer/my_import.dart';

class WalletTabContent extends StatelessWidget {
  const WalletTabContent({super.key});

  static final _skeleton = TransactionModel(
    id: '',
    userId: '',
    type: 'deposit',
    amount: 0,
    displayAmount: '+000',
    currency: 'USD',
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (p, c) =>
          p.transactionsStatus != c.transactionsStatus ||
          p.transactions != c.transactions ||
          p.walletData != c.walletData,
      builder: (context, state) {
        final isLoading = state.transactionsStatus == ListStatus.loading;
        final items = state.previewTransactions;

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary400,
                onRefresh: () => context.read<WalletCubit>().refresh(),
                child: SingleChildScrollView(
                  // AlwaysScrollableScrollPhysics ensures pull-to-refresh
                  // works even when content doesn't fill the screen
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: const BalanceCard(),
                      ),
                      SizedBox(height: 20.h),
                      WalletSectionHeader(
                        title: context.tr('transactions_log'),
                        onViewAll: () => Navigator.pushNamed(
                          context,
                          AppRouter.kTransactionsLogView,
                        ),
                      ),
                      Skeletonizer(
                        enabled: isLoading,
                        child: (items.isEmpty && !isLoading)
                            ? WalletEmptyState(
                                label: context.tr('no_transactions'),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: isLoading ? 5 : items.length,
                                itemBuilder: (_, i) => TransactionItem(
                                  transaction: isLoading ? _skeleton : items[i],
                                ),
                              ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 40.w),
              child: Row(
                children: [
                  Expanded(
                    child: CustomBotton(
                      height: 54.h,
                      width: double.infinity,
                      title: context.tr('withdraw'),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRouter.kWithdrawalView,
                      ),
                      useGradient: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomBotton(
                      height: 54.h,
                      width: double.infinity,
                      title: context.tr('recharge'),
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.kRechargeView),
                      useGradient: false,
                      backGroundcolor: AppColors.primary100,
                      titleColor: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class EarningsTabContent extends StatelessWidget {
  const EarningsTabContent({super.key});

  static final _skeleton = TransactionModel(
    id: '',
    userId: '',
    type: 'session_reservation',
    amount: 0,
    displayAmount: '+000',
    currency: 'USD',
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (p, c) =>
          p.earningsStatus != c.earningsStatus || p.earnings != c.earnings,
      builder: (context, state) {
        final isLoading = state.earningsStatus == ListStatus.loading;
        final items = state.previewEarnings;

        return RefreshIndicator(
          color: AppColors.primary400,
          onRefresh: () => context.read<WalletCubit>().refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                WalletSectionHeader(
                  title: context.tr('earnings_log'),
                  onViewAll: () =>
                      Navigator.pushNamed(context, AppRouter.kBookingsLogView),
                ),
                Skeletonizer(
                  enabled: isLoading,
                  child: (items.isEmpty && !isLoading)
                      ? WalletEmptyState(label: context.tr('no_bookings'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: isLoading ? 5 : items.length,
                          itemBuilder: (_, i) => TransactionItem(
                            transaction: isLoading ? _skeleton : items[i],
                          ),
                        ),
                ),
                SizedBox(height: 90.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
