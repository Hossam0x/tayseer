import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_cubit.dart';

class TransactionsLogView extends StatelessWidget {
  const TransactionsLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletCubit()..loadWalletTransactions(),
      child: Scaffold(
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 110.h,
                child: Image.asset(
                  AssetsData.homeBarBackgroundImage,
                  fit: BoxFit.fill,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Gap(16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SimpleAppBar(title: 'سجل المعاملات'),
                    ),
                    Gap(16.h),
                    BlocBuilder<WalletCubit, WalletState>(
                      builder: (context, state) {
                        if (state.status == WalletStatus.loading) {
                          return const Expanded(
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return Expanded(
                          child: ListView.builder(
                            itemCount: state.walletTransactions.length,
                            itemBuilder: (context, index) => TransactionItem(
                              transaction: state.walletTransactions[index],
                              showTime: true,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
