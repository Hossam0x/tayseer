import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RatingsTab extends StatelessWidget {
  final String advisorId;
  final bool isMe;

  const RatingsTab({super.key, required this.advisorId, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RatingsCubit>(
      create: (_) => getIt<RatingsCubit>(),
      child: _RatingsTabContent(advisorId: advisorId, isMe: isMe),
    );
  }
}

class _RatingsTabContent extends StatefulWidget {
  final String advisorId;
  final bool isMe;

  const _RatingsTabContent({required this.advisorId, required this.isMe});

  @override
  State<_RatingsTabContent> createState() => __RatingsTabContentState();
}

class __RatingsTabContentState extends State<_RatingsTabContent> {
  late RatingsCubit _cubit;
  bool _isInitialized = false;
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cubit = RatingsCubit(getIt<RatingsRepository>());
    _loadData();
  }

  Future<void> _loadData() async {
    if (!_isInitialized) {
      await _cubit.refresh(advisorId: widget.advisorId);
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> refreshFromParent() async {
    await _cubit.refresh(advisorId: widget.advisorId);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMe = widget.isMe;

    if (!_isInitialized) {
      return _buildSkeletonRatings();
    }

    return RefreshIndicator(
      onRefresh: () async => await _cubit.refresh(advisorId: widget.advisorId),
      child: Column(
        children: [
          // زر إضافة تقييم إذا لم يكن بروفايل المستخدم نفسه
          if (!isMe) _buildAddRatingButton(context),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              children: [
                // قسم الإحصائيات العلوي
                _buildSummarySection(_cubit.state),

                Gap(20.h),

                // قائمة التقييمات
                _buildRatingsList(context, _cubit.state),
              ],
            ),
          ),

          // زر تحميل المزيد للتقييمات
          if (_cubit.state.hasMore) _buildLoadMoreButton(context, _cubit.state),

          Gap(20.h),
        ],
      ),
    );
  }

  Widget _buildAddRatingButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      child: ElevatedButton(
        onPressed: () => _showRateDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kprimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          minimumSize: Size(double.infinity, 54.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: AppColors.kWhiteColor, size: 20.w),
            Gap(8.w),
            Text(
              'إضافة تقييم',
              style: Styles.textStyle16Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // العنوان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close, size: 24.w),
                      ),
                      Text(
                        'تقييم المستشار',
                        style: Styles.textStyle20Meduim.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      Gap(24.w),
                    ],
                  ),

                  Gap(25.h),

                  // النجوم للتقييم (قابلة للاختيار)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                        child: Icon(
                          // اختيار الأيقونة بناءً على التقييم
                          index < _rating
                              ? Icons.star_rounded
                              : Icons.star_rounded,
                          color: index < _rating
                              ? AppColors.kprimaryColor
                              : AppColors.secondary100,
                          size: 56.w,
                        ),
                      );
                    }),
                  ),

                  // عرض قيمة التقييم (اختياري)
                  if (_rating > 0) ...[
                    Gap(12.h),
                    Text(
                      'تقييمك: $_rating / 5',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.primary500,
                      ),
                    ),
                  ],

                  Gap(24.h),

                  // حقل كتابة المراجعة
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'اكتب مراجعتك',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),

                  Gap(24.h),

                  // زر الإرسال
                  _isSubmitting
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.kprimaryColor,
                          ),
                        )
                      : CustomBotton(
                          title: 'إرسال التقييم',
                          onPressed: () async {
                            if (_rating == 0) {
                              AppToast.error(
                                context,
                                'الرجاء اختيار عدد النجوم',
                              );
                              return;
                            }

                            setState(() {
                              _isSubmitting = true;
                            });

                            await _submitRating(
                              context,
                              _rating,
                              _reviewController.text,
                            );

                            setState(() {
                              _isSubmitting = false;
                            });

                            Navigator.pop(context);
                          },
                          width: double.infinity,
                          height: 54.h,
                          useGradient: true,
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitRating(
    BuildContext context,
    int rating,
    String review,
  ) async {
    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.post(
        endPoint: '/advisor-rating',
        data: {
          "rating": rating,
          "review": review,
          "advisorId": widget.advisorId,
        },
      );

      if (response['success'] == true) {
        AppToast.success(
          context,
          response['message'] ?? 'تم إرسال التقييم بنجاح',
        );
        _reviewController.clear();
        _rating = 0;

        // Refresh ratings
        await _cubit.refresh(advisorId: widget.advisorId);
      } else {
        AppToast.error(context, response['message'] ?? 'فشل إرسال التقييم');
      }
    } catch (e) {
      AppToast.error(context, 'حدث خطأ أثناء إرسال التقييم');
    }
  }

  Widget _buildSkeletonRatings() {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            // Summary skeleton
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Gap(16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                            width: 60.w,
                            height: 30.h,
                          ),
                          Gap(8.h),
                          Container(
                            width: 100.w,
                            height: 15.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Gap(8.h),
                          Container(
                            width: 80.w,
                            height: 15.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      Gap(24.w),
                      Expanded(
                        child: Column(
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20.w,
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Gap(12.w),
                                  Expanded(
                                    child: Container(
                                      height: 8.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  Gap(12.w),
                                  Container(
                                    width: 60.w,
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(20.h),
            // Ratings list skeleton
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 100.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Container(
                                width: 80.w,
                                height: 15.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          Gap(12.h),
                          Container(
                            width: double.infinity,
                            height: 80.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSummarySection(RatingsState state) {
    final starsBreakdown = state.starsBreakdown;

    // ⭐ الحل: التحقق من maxStarCount لتجنب القسمة على صفر
    final maxStarCount = starsBreakdown[5] ?? 0;
    final safeMaxStarCount = maxStarCount > 0 ? maxStarCount : 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // التقييم الكبير على اليمين
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.averageRating.toStringAsFixed(1),
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
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Icon(
                          Icons.star,
                          size: 20.sp,
                          color: AppColors.primary400,
                        ),
                      ),
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    '${state.totalRatings} تقييم',
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
                        padding: EdgeInsets.only(bottom: 8.h),
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
                                  // ⭐ الحل: التحقق من القيمة لتجنب NaN أو Infinity
                                  value: safeMaxStarCount > 0
                                      ? (starsBreakdown[i] ?? 0) /
                                            safeMaxStarCount
                                      : 0,
                                  backgroundColor: AppColors.barGreyColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary400,
                                  ),
                                  minHeight: 8.h,
                                ),
                              ),
                            ),
                            Gap(12.w),
                            // النسبة والنص
                            Text(
                              starsBreakdown[i] == 0
                                  ? 'لا يوجد'
                                  : '${starsBreakdown[i]} تقييم',
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.primaryText,
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
    );
  }

  Widget _buildRatingsList(BuildContext context, RatingsState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.ratings.length,
      separatorBuilder: (context, index) => Gap(16.h),
      itemBuilder: (context, index) {
        final rating = state.ratings[index];

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المستخدم
              SizedBox(
                width: 60.r,
                height: 60.r,
                child: CircleAvatar(
                  backgroundImage: rating.user.image != null
                      ? NetworkImage(rating.user.image!)
                      : null,
                  child: rating.user.image == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.hintText,
                          size: 24.sp,
                        )
                      : null,
                ),
              ),
              Gap(12.w),
              // محتوى التقييم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (الاسم + التاريخ)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rating.user.name ?? 'مستخدم',
                          style: Styles.textStyle16Bold.copyWith(
                            color: AppColors.primaryText,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          _formatDate(rating.createdAt),
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.secondaryText,
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
                            starIndex < rating.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 18.sp,
                            color: AppColors.primary400,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.h),
                    // نص التقييم
                    Text(
                      rating.review,
                      textAlign: TextAlign.right,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondaryText,
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
    );
  }

  String _formatDate(String dateString) {
    try {
      // 1️⃣ parse التاريخ بصيغته الصح
      final parsedDate = DateFormat(
        'M/d/yyyy, hh:mm:ss a',
        'en',
      ).parse(dateString);

      // 2️⃣ عرضه بالعربي ومن غير وقت
      return DateFormat('dd MMMM yyyy', 'ar').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildLoadMoreButton(BuildContext context, RatingsState state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: state.isLoadingMore
          ? Center(
              child: CircularProgressIndicator(color: AppColors.kprimaryColor),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _cubit.fetchRatings(
                  advisorId: widget.advisorId,
                  loadMore: true,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kWhiteColor,
                  foregroundColor: AppColors.kprimaryColor,
                  side: BorderSide(color: AppColors.kprimaryColor, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                ),
                child: Text(
                  'تحميل المزيد من التقييمات',
                  style: Styles.textStyle14Meduim.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
    );
  }
}
