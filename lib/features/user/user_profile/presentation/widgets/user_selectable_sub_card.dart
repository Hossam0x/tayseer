import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';
import 'package:tayseer/my_import.dart';

class UserSelectableSubCard extends StatelessWidget {
  final NewUserSubModel sub;
  final bool isSelected;
  final VoidCallback? onTap;

  const UserSelectableSubCard({
    super.key,
    required this.sub,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();
    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : sub.isThreeMonths
        ? context.tr('three_months')
        : context.tr('monthly');
    final priceText = sub.price != null
        ? '${sub.price} $currency'
        : context.tr('price_not_available');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary200
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    durationLabel,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: isSelected
                          ? AppColors.blackColor
                          : AppColors.secondary700,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    priceText,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary600
                      : AppColors.secondary700,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: 16.sp,
                        color: AppColors.primary600,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
