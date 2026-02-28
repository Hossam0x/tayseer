import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/data/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class BookingsLogView extends StatelessWidget {
  const BookingsLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<WalletCubit>()..getAllTransactions(),
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
                      child: SimpleAppBar(title: context.tr('bookings_log')),
                    ),
                    Gap(16.h),
                    BlocBuilder<WalletCubit, WalletState>(
                      builder: (context, state) {
                        return Expanded(
                          child: Skeletonizer(
                            enabled: state.status == WalletStatus.loading,
                            child: ListView.builder(
                              itemCount: state.status == WalletStatus.loading
                                  ? 10
                                  : state.bookingTransactions.length,
                              itemBuilder: (context, index) => TransactionItem(
                                transaction:
                                    state.status == WalletStatus.loading
                                    ? TransactionModel(
                                        id: '',
                                        amount: 0,
                                        displayAmount: '+000',
                                        type: 'event',
                                        eventTicketsNumber: 0,
                                        formattedDate: '24 ديسمبر 2025',
                                      )
                                    : state.bookingTransactions[index],
                                showTime: true,
                              ),
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
