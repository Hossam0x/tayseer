import 'package:tayseer/my_import.dart';

class PackageCard extends StatelessWidget {
  final String title;
  final List<String> features;
  final String price;
  final String savings;
  final bool isFeatured;
  final VoidCallback onSubscribe;

  const PackageCard({
    super.key,
    required this.title,
    required this.features,
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
        color: isFeatured ? AppColors.backCardBaqa : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isFeatured ? Border.all(color: const Color(0xFFF18DA3)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Styles.textStyle14SemiBold.copyWith(
                  color: AppColors.titleCard,
                ),
              ),
              Gap(8.h),
              ...features.map(
                (f) => Text(
                  '• $f',
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.secondary600,
                  ),
                ),
              ),
              Gap(12.h),
              GradientText(text: '$price EGP', style: Styles.textStyle20Bold),
              Gap(8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.tabsBack,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  'وفر $savings Egp',
                  style: Styles.textStyle14Meduim.copyWith(
                    color: AppColors.titleCard,
                  ),
                ),
              ),
            ],
          ),

          CustomBotton(
            title: 'اشتراك',
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
