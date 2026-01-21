import 'package:tayseer/my_import.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String dateStart;
  final String dateEnd;
  final bool isExpiring;
  final bool canRenew;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.dateStart,
    required this.dateEnd,
    this.isExpiring = false,
    this.canRenew = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.secondary950.withOpacity(0.75),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.secondary50),
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
                  Gap(5.h),
                  Text(
                    '3 محادثات , تعزيز البوستات , تثبيت في \n الاعلي لمدة يوم',
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.secondary600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  Gap(10.h),
                  Text(
                    'تاريخ التجديد : $dateStart',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                  Text(
                    'تاريخ الانتهاء : $dateEnd',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                  Gap(10.h),
                ],
              ),

              Column(
                children: [
                  Gap(14.h),
                  GradientText(text: '170 EGP', style: Styles.textStyle20Bold),
                  Gap(10.h),
                  CustomBotton(
                    title: 'تجديد',
                    onPressed: canRenew ? () {} : null,
                    width: 95.w,
                    height: 45.h,
                    useGradient: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isExpiring)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color.fromRGBO(246, 210, 66, 1),
                    Color.fromRGBO(255, 82, 229, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                  topRight: Radius.zero,
                  bottomLeft: Radius.zero,
                ),
              ),
              child: Text(
                'اوشكت علي الانتهاء',
                style: Styles.textStyle14.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
