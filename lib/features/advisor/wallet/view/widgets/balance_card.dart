import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_state.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, state) {
        final balance = state.walletData?.balance ?? 0;
        final currency = state.walletData?.currency ?? context.tr('egp');

        return Skeletonizer(
          enabled: state.status == WalletStatus.loading,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.whiteCardBack,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.kWhiteColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('current_balance'),
                  style: Styles.textStyle20.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                Text(
                  '$balance $currency',
                  style: Styles.textStyle32Bold.copyWith(
                    color: AppColors.primary400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
