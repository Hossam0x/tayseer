import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class BookingsLogView extends StatefulWidget {
  const BookingsLogView({super.key});

  @override
  State<BookingsLogView> createState() => _BookingsLogViewState();
}

class _BookingsLogViewState extends State<BookingsLogView> {
  late final ScrollController _scrollController;
  late final WalletCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<WalletCubit>()..fetchEarnings(refresh: true);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _cubit.fetchEarnings();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
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
                      child: SimpleAppBar(title: context.tr('earnings_log')),
                    ),
                    Gap(16.h),
                    Expanded(
                      child: BlocBuilder<WalletCubit, WalletState>(
                        buildWhen: (p, c) =>
                            p.earningsStatus != c.earningsStatus ||
                            p.earnings != c.earnings,
                        builder: (context, state) {
                          final isLoading =
                              state.earningsStatus == ListStatus.loading;
                          final isLoadingMore =
                              state.earningsStatus == ListStatus.loadingMore;
                          final items = state.earnings;

                          return Skeletonizer(
                            enabled: isLoading,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: isLoading
                                  ? 10
                                  : items.length + (isLoadingMore ? 1 : 0),
                              itemBuilder: (context, i) {
                                if (!isLoading && i == items.length) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 16.h,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return TransactionItem(
                                  transaction: isLoading ? _skeleton : items[i],
                                );
                              },
                            ),
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
    );
  }

  static const _skeleton = TransactionModel(
    id: '',
    userId: '',
    type: 'session_reservation',
    amount: 0,
    displayAmount: '+000',
    currency: 'USD',
  );
}
