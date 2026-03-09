import 'package:tayseer/my_import.dart';

class SimpleAppBar extends StatelessWidget {
  final String title;
  final bool? isLargeTitle;
  final IconData? icon; // خليناه nullable عشان نقدر نميّز
  final VoidCallback? onBack;
  final bool isUserTicket; // ✅ إضافة معامل isUserTicket

  const SimpleAppBar({
    super.key,
    required this.title,
    this.isLargeTitle,
    this.icon,
    this.onBack,
    this.isUserTicket = false, // ✅ القيمة الافتراضية false
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = isLargeTitle == true
        ? Styles.textStyle24SemiBold.copyWith(color: AppColors.primary800)
        : Styles.textStyle20Meduim.copyWith(color: AppColors.secondary700);

    final bool useCustomBackIcon = icon == null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// زر الرجوع / الإغلاق
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onBack ?? () => Navigator.maybePop(context),
              borderRadius: BorderRadius.circular(24.r),
              child: Padding(
                padding: EdgeInsets.all(12.w),

                child: useCustomBackIcon
                    ? Transform.flip(
                        flipX: Directionality.of(context) == TextDirection.ltr,
                        child: AppImage(AssetsData.backArrow, width: 19.w),
                      )
                    : Icon(
                        icon,
                        color: icon == Icons.close
                            ? AppColors.secondary600
                            : AppColors.blackColor,
                        size: 24.w,
                      ),
              ),
            ),
          ),
        ),

        /// العنوان
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 16.h),
            child: Center(
              child: Text(
                title,
                style: titleStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),

        /// ✅ أيقونة التذاكر (تظهر فقط للـ user)
        if (isUserTicket)
          Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.pushNamed(AppRouter.kMyTicketsView);
                },
                borderRadius: BorderRadius.circular(24.r),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary100,
                  ),
                  child: AppImage(AssetsData.kTicketIcon, width: 20.w),
                ),
              ),
            ),
          )
        else
          SizedBox(width: 40.w),
      ],
    );
  }
}
