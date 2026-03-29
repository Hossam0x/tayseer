import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/wallet/data/models/balance_package_model.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/recharge_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/recharge_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/package_card.dart';
import 'package:tayseer/my_import.dart';

class RechargePackagesGrid extends StatelessWidget {
  const RechargePackagesGrid({super.key});

  static final _skeletonPackages = List.generate(
    6,
    (_) => BalancePackageModel(
      id: '',
      balance: 100,
      appleProductId: '',
      price: 1.5,
      currency: 'USD',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RechargeCubit, RechargeState>(
      builder: (context, state) {
        final isLoading = state.status == RechargeStatus.loading;
        final packages = isLoading ? _skeletonPackages : state.packages;

        return Skeletonizer(
          enabled: isLoading,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
            ),
            itemCount: packages.length,
            itemBuilder: (_, i) => PackageCard(
              package: packages[i],
              isSelected: state.selectedIndex == i,
              onTap: () => context.read<RechargeCubit>().selectPackage(i),
            ),
          ),
        );
      },
    );
  }
}
