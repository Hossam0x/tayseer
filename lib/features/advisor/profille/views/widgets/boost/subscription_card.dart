import 'package:tayseer/my_import.dart';

class SubscriptionCard extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String? subtitle;
  final List<String> features;
  final bool isBestValue;
  final VoidCallback onTap;

  const SubscriptionCard({
    super.key,
    required this.isSelected,
    required this.title,
    this.subtitle,
    this.features = const [],
    required this.isBestValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card Container
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary200 : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.2),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: isSelected
                            ? AppColors.blackColor
                            : AppColors.boostUnactive,
                      ),
                    ),

                    if (isSelected &&
                        (subtitle != null || features.isNotEmpty)) ...[
                      Gap(4.h),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Styles.textStyle10.copyWith(
                            color: AppColors.blackColor.withOpacity(0.7),
                          ),
                        ),
                      Gap(8.h),
                      ...features.map(
                        (feature) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 4.sp,
                                color: AppColors.blackColor,
                              ),
                              Gap(6.w),
                              Text(
                                feature,
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Radio Button Logic
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary600
                          : AppColors.boostUnactive,
                      width: 1.5,
                    ),
                    color: isSelected ? Colors.transparent : Colors.transparent,
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

          // "Best Value" Badge
          if (isBestValue)
            Positioned(
              top: -13.h,
              right: 25.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color.fromRGBO(245, 192, 3, 1),
                      Color.fromRGBO(228, 78, 108, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.r),
                    bottomLeft: Radius.circular(20.r),
                    topLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                ),
                child: Text(
                  'أفضل قيمة',
                  style: Styles.textStyle12SemiBold.copyWith(
                    color: AppColors.secondary950,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
