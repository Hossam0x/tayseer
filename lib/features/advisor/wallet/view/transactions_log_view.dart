import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/wallet_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/transaction_item.dart';
import 'package:tayseer/features/advisor/wallet/data/models/transaction_model.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class TransactionsLogView extends StatefulWidget {
  const TransactionsLogView({super.key});

  @override
  State<TransactionsLogView> createState() => _TransactionsLogViewState();
}

class _TransactionsLogViewState extends State<TransactionsLogView> {
  final _scrollController = ScrollController();
  late final WalletCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<WalletCubit>()..fetchTransactions(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _cubit.fetchTransactions();
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
                      child: SimpleAppBar(
                        title: context.tr('transactions_log'),
                      ),
                    ),
                    Gap(16.h),
                    Expanded(
                      child: BlocBuilder<WalletCubit, WalletState>(
                        buildWhen: (p, c) =>
                            p.transactionsStatus != c.transactionsStatus ||
                            p.transactions != c.transactions,
                        builder: (context, state) {
                          final isLoading =
                              state.transactionsStatus == ListStatus.loading;
                          final isLoadingMore =
                              state.transactionsStatus ==
                              ListStatus.loadingMore;

                          return Skeletonizer(
                            enabled: isLoading,
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: isLoading
                                  ? 10
                                  : state.transactions.length +
                                        (isLoadingMore ? 1 : 0),
                              itemBuilder: (_, i) {
                                if (isLoading) {
                                  return TransactionItem(
                                    transaction: _skeletonItem,
                                  );
                                }
                                if (i == state.transactions.length) {
                                  return const _LoadingMoreIndicator();
                                }
                                return TransactionItem(
                                  transaction: state.transactions[i],
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

  static final _skeletonItem = TransactionModel(
    id: '',
    userId: '',
    type: 'deposit',
    amount: 0,
    displayAmount: '+000',
    currency: 'USD',
  );
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
