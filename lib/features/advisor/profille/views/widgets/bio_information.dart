import 'package:flutter/cupertino.dart';
import 'package:tayseer/my_import.dart';

class BioInformation extends StatelessWidget {
  const BioInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dr / Anna Mary",
              style: Styles.textStyle20SemiBold.copyWith(
                color: AppColors.blueText,
              ),
            ),
            Gap(4.h),
            Text(
              "@annanoo",
              style: Styles.textStyle14.copyWith(color: AppColors.hintText),
            ),
            Gap(8.h),
            Text(
              "استشاري نفسي وعلاقات زوجية",
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
              textAlign: TextAlign.start,
            ),
            Gap(4.h),
            Text(
              "سنين من الخبرة",
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.secondary800,
              ),
              textAlign: TextAlign.start,
            ),
            Gap(4.h),
            Row(
              children: [
                AppImage(AssetsData.locationIcon, width: 12.w),
                Gap(4),
                Text(
                  'مصر, دمياط الجديدة',
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary800,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            Text(
              "استشاري نفسي مع خبرة تزيد عن [عدد السنوات] سنوات في تقديم الدعم النفسي والإرشاد للأفراد. أساعد الأشخاص في التغلب على تحديات مثل العلاج المعرفي السلوكي (CBT).",
              style: Styles.textStyle14.copyWith(
                color: AppColors.infoText,
                height: 1.5,
              ),
              textAlign: TextAlign.start,
            ),
            Gap(24.h),
            // Consultation packages button
            InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.kProfessionalInfoDashboardView,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.cBackground100,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.primary300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "لوحة المعلومات الاحترافية",
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: AppColors.blackColor,
                      ),
                    ),
                    Gap(12.h),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_up_left,
                          color: AppColors.secondary700,
                          size: 24.w,
                        ),
                        Gap(8),
                        Text(
                          "1350 ألف مشاهدة خلال 30 يوم.",
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
