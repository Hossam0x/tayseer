import 'package:tayseer/features/advisor/wallet/data/models/balance_package_model.dart';
import 'package:tayseer/my_import.dart';

class PackageCard extends StatelessWidget {
  final BalancePackageModel package;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary100 : AppColors.whiteCardBack,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary400 : AppColors.kWhiteColor,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary400.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? AppColors.defaultGradient
                    : LinearGradient(
                        colors: [AppColors.primary100, AppColors.primary200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Center(
                child: Text(
                  '${package.balance}',
                  style: Styles.textStyle16Bold.copyWith(
                    color: isSelected
                        ? AppColors.kWhiteColor
                        : AppColors.primary500,
                  ),
                ),
              ),
            ),
            Gap(15.h),
            Text(
              context.tr('price_label', args: ['${package.price}']),
              style: Styles.textStyle16SemiBold.copyWith(
                color: isSelected
                    ? AppColors.primary500
                    : AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
