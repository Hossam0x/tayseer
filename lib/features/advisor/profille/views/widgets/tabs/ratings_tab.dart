import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/my_import.dart';

class RatingsTab extends StatelessWidget {
  const RatingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // بيانات تجريبية للتقييمات
    final List<Map<String, dynamic>> ratings = [
      {
        'userName': 'صلاح محسن',
        'userImage': 'assets/images/user1.jpg',
        'rating': 5,
        'date': '17 ديسمبر 2024',
        'comment':
            'أسلوب المحاضرة ممتاز جداً وبيشرح بالأمان. شرحات بتخلصني كبير بعد عدة جلسات، وأصبحت إن الأمور من منظور أكثر إيجابية.',
      },
      {
        'userName': 'محمد حمزة',
        'userImage': 'assets/images/user2.jpg',
        'rating': 5,
        'date': '21 فبراير 2024',
        'comment':
            'الطبيب ممتاز في عمله ويفهم بادق التفاصيل، لكن أحياناً يكون من الصعب حجز موعد قريب بسبب ازدحام الجداول',
      },
      {
        'userName': 'محمد خليفة',
        'userImage': 'assets/images/user3.jpg',
        'rating': 5,
        'date': '19 فبراير 2024',
        'comment':
            'العلاج كان محترف جداً، استمع لي باهتمام وساعدني في التعامل مع مشاكل بطريقة عقلانية ومنطقية. أشعر بتحسن كبير بعد الجلسات القليلة الأولى، أنصح به بشدة!',
      },
    ];

    // إحصائيات التقييمات
    final Map<int, int> ratingCounts = {5: 306, 4: 59, 3: 24, 2: 9, 1: 0};

    final double averageRating = 4.8;
    final int totalReviews = 398;

    if (ratings.isEmpty) {
      return const SharedEmptyState(title: "لا توجد تقييمات");
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        children: [
          // قسم الإحصائيات العلوي
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),

            child: Column(
              children: [
                Gap(16.h),
                // التقييم الإجمالي
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // التقييم الكبير على اليمين
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Gap(4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                              child: Icon(
                                Icons.star,
                                size: 15.sp,
                                color: AppColors.primary400,
                              ),
                            ),
                          ),
                        ),
                        Gap(8.h),
                        Text(
                          '$totalReviews تقييم',
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Gap(8.h),
                      ],
                    ),
                    Gap(24.w),
                    // البارات والأرقام
                    Expanded(
                      child: Column(
                        children: [
                          for (int i = 5; i >= 1; i--)
                            Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Row(
                                children: [
                                  // النجوم والرقم
                                  Row(
                                    children: [
                                      Text(
                                        '$i',
                                        style: Styles.textStyle14.copyWith(
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                      Gap(4.w),
                                      Icon(
                                        Icons.star,
                                        size: 16.sp,
                                        color: AppColors.primary400,
                                      ),
                                    ],
                                  ),
                                  Gap(12.w),
                                  // شريط التقدم
                                  Expanded(
                                    flex: 2,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4.r),
                                      child: LinearProgressIndicator(
                                        value:
                                            ratingCounts[i]! / ratingCounts[5]!,
                                        backgroundColor: const Color(
                                          0xFFE5E7EB,
                                        ),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.primary400,
                                            ),
                                        minHeight: 8.h,
                                      ),
                                    ),
                                  ),

                                  Gap(12.w),

                                  // النسبة والنص
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          ratingCounts[i] == 0
                                              ? 'لا يوجد'
                                              : '${ratingCounts[i]} تقييم',
                                          style: Styles.textStyle12.copyWith(
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Gap(10.h),
          // قائمة التقييمات
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ratings.length,
            separatorBuilder: (context, index) => Gap(12.h),
            itemBuilder: (context, index) {
              final rating = ratings[index];

              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // الصورة الشخصية
                    SizedBox(
                      width: 60.r,
                      height: 60.r,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFE5E7EB),
                        backgroundImage: AssetImage(AssetsData.avatarImage),
                        child: rating['userImage'] == null
                            ? Icon(
                                Icons.person,
                                color: Colors.grey.shade400,
                                size: 22.sp,
                              )
                            : null,
                      ),
                    ),
                    Gap(12.w),
                    // محتوى التقييم كله
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Header (الاسم + التاريخ)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rating['userName'],
                                style: Styles.textStyle16Bold.copyWith(
                                  color: const Color(0xFF111827),
                                ),
                                textAlign: TextAlign.right,
                              ),
                              Text(
                                rating['date'],
                                style: Styles.textStyle12.copyWith(
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),

                          Gap(8.h),

                          // النجوم
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: List.generate(
                              5,
                              (starIndex) => Padding(
                                padding: EdgeInsets.only(left: 2.w),
                                child: Icon(
                                  starIndex < rating['rating']
                                      ? Icons.star
                                      : Icons.star_border,
                                  size: 18.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),

                          Gap(12.h),

                          // نص التقييم
                          Text(
                            rating['comment'],
                            textAlign: TextAlign.right,
                            style: Styles.textStyle14.copyWith(
                              color: const Color(0xFF6B7280),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // زر تحميل المزيد
          Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _loadMoreReviews(context);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.kprimaryColor, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'تحميل المزيد من التقييمات',
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.kprimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          Gap(20.h),
        ],
      ),
    );
  }

  // دالة تحميل المزيد
  void _loadMoreReviews(BuildContext context) {
    // TODO: تنفيذ تحميل المزيد من التقييمات
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        context,
        isSuccess: true,
        text: "جاري تحميل المزيد من التقييمات...",
      ),
    );
  }
}
