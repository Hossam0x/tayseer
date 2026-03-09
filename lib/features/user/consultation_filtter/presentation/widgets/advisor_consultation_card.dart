import 'package:tayseer/my_import.dart';

class AdvisorConsultationCard extends StatelessWidget {
  final bool isSelected;
  const AdvisorConsultationCard({super.key, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      // 1. Use Stack to overlay the badge
      children: [
        Container(
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
                        // ... Star Rating Row ...
                        Row(
                          children: [
                            Row(
                              children: List.generate(5, (starIndex) {
                                return Icon(
                                  starIndex < 4
                                      ? Icons.star
                                      : Icons.star_border,
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
                            // ... rest of your rating info
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              CustomBotton(
                title: context.tr("book_session"),
                onPressed: () {},
                height: 50.h,
                width: double
                    .infinity, // Changed to double.infinity for responsiveness
              ),
            ],
          ),
        ),
        // 2. Position the Badge absolutely
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
    );
  }
}
// import 'package:tayseer/features/user/consultation_filtter/data/models/advisor_model.dart';
// import 'package:tayseer/my_import.dart';

// class AdvisorConsultationCard extends StatelessWidget {
//   final AdvisorFilterModel advisor;
//   final bool isSelected;

//   const AdvisorConsultationCard({
//     super.key,
//     required this.advisor,
//     this.isSelected = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Container(
//           padding: EdgeInsets.all(16.w),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color.fromRGBO(255, 240, 243, 1)
//                 : Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             border: isSelected ? Border.all(color: AppColors.primary300) : null,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(40.r),
//                     child: advisor.imageUrl != null
//                         ? Image.network(
//                             advisor.imageUrl!,
//                             width: 66.w,
//                             height: 66.w,
//                             fit: BoxFit.cover,
//                             errorBuilder: (_, __, ___) => AppImage(
//                               AssetsData.kUserImage,
//                               width: 66.w,
//                               height: 66.w,
//                               fit: BoxFit.cover,
//                             ),
//                           )
//                         : AppImage(
//                             AssetsData.kUserImage,
//                             width: 66.w,
//                             height: 66.w,
//                             fit: BoxFit.cover,
//                           ),
//                   ),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           advisor.name,
//                           style: Styles.textStyle18SemiBold.copyWith(
//                             color: AppColors.secondary800,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: 4.h),
//                         Text(
//                           advisor.specialty,
//                           style: Styles.textStyle14.copyWith(
//                             color: AppColors.secondary400,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                         SizedBox(height: 6.h),
//                         Row(
//                           children: [
//                             Row(
//                               children: List.generate(5, (starIndex) {
//                                 return Icon(
//                                   starIndex < advisor.rating.round()
//                                       ? Icons.star
//                                       : Icons.star_border,
//                                   color: starIndex < advisor.rating.round()
//                                       ? AppColors.kprimaryColor
//                                       : AppColors.secondary200,
//                                   size: 18.sp,
//                                 );
//                               }),
//                             ),
//                             SizedBox(width: 6.w),
//                             Text(
//                               advisor.rating.toStringAsFixed(1),
//                               style: Styles.textStyle14.copyWith(
//                                 color: AppColors.secondary400,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                             SizedBox(width: 4.w),
//                             Container(
//                               height: 12.h,
//                               width: 1.w,
//                               color: AppColors.secondary400,
//                             ),
//                             SizedBox(width: 4.w),
//                             Text(
//                               "${advisor.reviewsCount} ${context.tr("reviews")}",
//                               style: Styles.textStyle14.copyWith(
//                                 color: AppColors.secondary400,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20.h),
//               CustomBotton(
//                 title: context.tr("book_session"),
//                 onPressed: () {},
//                 height: 50.h,
//                 width: double.infinity,
//               ),
//             ],
//           ),
//         ),
//         if (isSelected)
//           Positioned(
//             top: 16.h,
//             left: isArabic ? 16.w : null,
//             right: isArabic ? null : 16.w,
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//               decoration: BoxDecoration(
//                 color: AppColors.primary300,
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Text(
//                 context.tr("recommended"),
//                 style: Styles.textStyle12.copyWith(color: Colors.white),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }