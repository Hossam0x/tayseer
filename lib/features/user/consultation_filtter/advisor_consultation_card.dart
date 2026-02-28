
import 'package:tayseer/my_import.dart';

class AdvisorConsultationCard extends StatelessWidget {
  final bool isSelected; // ✅ add this
  const AdvisorConsultationCard({super.key, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromRGBO(255, 240, 243, 1)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: isSelected ? Border.all(color: AppColors.primary300) : null,
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
              ClipRRect(
                borderRadius: BorderRadius.circular(40.r),
                child: AppImage(
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
                    Text(
                      "د/ احمد علي",
                      style: Styles.textStyle18SemiBold.copyWith(
                        color: AppColors.secondary800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "اخصائي علاج علاقاتي ممتاز",
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary400,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Row(
                          children: List.generate(5, (starIndex) {
                            return Icon(
                              starIndex < 4 ? Icons.star : Icons.star_border,
                              color: starIndex < 4
                                  ? AppColors.kprimaryColor
                                  : AppColors.secondary200,
                              size: 18.sp,
                            );
                          }),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "4.8",
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
                          "398 ${context.tr("reviews")}",
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary400,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ✅ Badge shows only when isSelected == true
              if (isSelected)
                Container(
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
            ],
          ),
          SizedBox(height: 20.h),
          CustomBotton(title: context.tr("book_session"), onPressed: () {},height: 50.h,width: 400.w,),
        ],
      ),
    );
  }
}
