import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/balance_card.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

/// Tab 1 — المحفظة (transactions)
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

        return SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: const BalanceCard(),
              ),
              SizedBox(height: 20.h),
              _SectionHeader(
                title: context.tr('transactions_log'),
                onViewAll: () => Navigator.pushNamed(
                  context,
                  AppRouter.kTransactionsLogView,
                ),
              ),
              Skeletonizer(
                enabled: isLoading,
                child: (items.isEmpty && !isLoading)
                    ? _EmptyState(label: context.tr('no_transactions'))
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 40.w),
                child: CustomBotton(
                  height: 54.h,
                  width: double.infinity,
                  title: context.tr('withdraw'),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.kWithdrawalView),
                  useGradient: true,
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

/// Tab 2 — الأرباح (earnings)
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

        return SingleChildScrollView(
          child: Column(
            children: [
              _SectionHeader(
                title: context.tr('earnings_log'),
                onViewAll: () =>
                    Navigator.pushNamed(context, AppRouter.kBookingsLogView),
              ),
              Skeletonizer(
                enabled: isLoading,
                child: (items.isEmpty && !isLoading)
                    ? _EmptyState(label: context.tr('no_bookings'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: isLoading ? 5 : items.length,
                        itemBuilder: (_, i) => TransactionItem(
                          transaction: isLoading ? _skeleton : items[i],
                        ),
                      ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 25.w, left: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              context.tr('view_all'),
              style: Styles.textStyle14.copyWith(color: AppColors.primary400),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Text(
        label,
        style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
      ),
    );
  }
}
