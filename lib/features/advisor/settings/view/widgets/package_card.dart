import 'package:tayseer/my_import.dart';

class PackageCard extends StatelessWidget {
  final String title;
  final List<String>? features;
  final String price;
  final String savings;
  final bool isFeatured;
  final VoidCallback onSubscribe;

  const PackageCard({
    super.key,
    required this.title,
    this.features,
    required this.price,
    required this.savings,
    this.isFeatured = false,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isFeatured
            ? AppColors.backCardBaqa
            : AppColors.secondary950.withOpacity(0.75),
        borderRadius: BorderRadius.circular(20.r),
        border: isFeatured ? Border.all(color: const Color(0xFFF18DA3)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Styles.textStyle14SemiBold.copyWith(
                    color: AppColors.titleCard,
                  ),
                ),

                Gap(8.h),

                // عرض features فقط إذا كانت موجودة
                if (features != null && features!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features!
                        .map(
                          (f) => Text(
                            '• $f',
                            style: Styles.textStyle12.copyWith(
                              color: AppColors.secondary600,
                            ),
                          ),
                        )
                        .toList(),
                  ),

                Gap(12.h),

                GradientText(
                  text: '$price ${context.tr('egp')}',
                  style: Styles.textStyle20Bold,
                ),

                Gap(8.h),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.tabsBack,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    context.tr('save_amount_egp', args: [savings]),
                    style: Styles.textStyle14Meduim.copyWith(
                      color: AppColors.titleCard,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Gap(16.w),

          CustomBotton(
            title: context.tr('subscribe'),
            onPressed: onSubscribe,
            width: 95.w,
            height: 45.h,
            useGradient: true,
          ),
        ],
      ),
    );
  }
}
