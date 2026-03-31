import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_state.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (prev, curr) =>
          prev.walletStatus != curr.walletStatus ||
          prev.walletData != curr.walletData,
      builder: (context, state) {
        final balance = state.walletData?.balance ?? 0;
        final currency = state.walletData?.currency ?? 'USD';
        final points = state.walletData?.points ?? 0;
        final isLoading = state.walletStatus == WalletStatus.loading;

        return Skeletonizer(
          enabled: isLoading,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: AppColors.backgroundGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary400.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Balance row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.tr('current_balance'),
                      style: Styles.textStyle14.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    Text(
                      '$balance $currency',
                      style: Styles.textStyle28Bold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(color: Colors.white.withOpacity(0.25), thickness: 1),
                SizedBox(height: 12.h),
                // ── Points row ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          color: Colors.amber,
                          size: 18.w,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          context.tr('points'),
                          style: Styles.textStyle14.copyWith(
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        '$points',
                        style: Styles.textStyle14SemiBold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
