import 'package:tayseer/features/user/consultation_filtter/data/models/advisor_model.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/my_import.dart';

class AdvisorConsultationCard extends StatelessWidget {
  final AdvisorFilterModel advisor;
  final bool isSelected;

  const AdvisorConsultationCard({
    super.key,
    required this.advisor,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserAdvisorProfileView(advisorId: advisor.id),
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromRGBO(255, 240, 243, 1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: isSelected
                  ? Border.all(color: AppColors.primary300)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // ✅ صورة حقيقية من الـ API أو placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40.r),
                      child: advisor.imageUrl != null
                          ? Image.network(
                              advisor.imageUrl!,
                              width: 66.w,
                              height: 66.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => AppImage(
                                AssetsData.kUserImage,
                                width: 66.w,
                                height: 66.w,
                                fit: BoxFit.cover,
                              ),
                            )
                          : AppImage(
                              AssetsData.kUserImage,
                              width: 66.w,
                              height: 66.w,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ✅ اسم حقيقي من الـ API
                          Text(
                            advisor.name,
                            style: Styles.textStyle18SemiBold.copyWith(
                              color: AppColors.secondary800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // ✅ subtitle حقيقي من الـ API
                          Text(
                            context.tr(advisor.subtitle),
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.secondary400,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          // ✅ Rating حقيقي من الـ API
                          Row(
                            children: [
                              Row(
                                children: List.generate(5, (starIndex) {
                                  return Icon(
                                    starIndex < advisor.rate.round()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: starIndex < advisor.rate.round()
                                        ? AppColors.kprimaryColor
                                        : AppColors.secondary200,
                                    size: 18.sp,
                                  );
                                }),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                advisor.rate.toStringAsFixed(1),
                                style: Styles.textStyle14.copyWith(
                                  color: AppColors.secondary400,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Container(
                                height: 12.h,
                                width: 1.w,
                                color: AppColors.secondary400,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                "${advisor.rateCount} ${context.tr("reviews")}",
                                style: Styles.textStyle14.copyWith(
                                  color: AppColors.secondary400,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          // ✅ أرخص سعر من الـ prices list
                          if (advisor.prices.isNotEmpty)
                            Text(
                              "${context.tr("from")} ${advisor.minPrice.toInt()} ${advisor.prices.first.currency}",
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.kprimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                CustomBotton(
                  title: context.tr("book_session"),
                  onPressed: () {
                    context.pushNamed(
                      AppRouter.kChooseSessionView,
                      arguments: {"title": "حجز جلسه", "advisorId": advisor.id},
                    );
                  },
                  height: 50.h,
                  width: double.infinity,
                ),
              ],
            ),
          ),
          // ✅ Badge "recommended" لو isSelected
          if (isSelected)
            Positioned(
              top: 16.h,
              left: isArabic ? 16.w : null,
              right: isArabic ? null : 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary300,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  context.tr("recommended"),
                  style: Styles.textStyle12.copyWith(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
