import 'package:intl/intl.dart';
import 'package:tayseer/core/cubits/int_cubit.dart';
import 'package:tayseer/core/cubits/toggle_cubit.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RatingsTab extends StatefulWidget {
  final String advisorId;
  final bool isMe;
  const RatingsTab({super.key, required this.advisorId, required this.isMe});

  @override
  State<RatingsTab> createState() => _RatingsTabState();
}

class _RatingsTabState extends State<RatingsTab>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _reviewController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isMe = widget.isMe;

    return BlocBuilder<RatingsCubit, RatingsState>(
      builder: (context, state) {
        if (state.state == CubitStates.loading && !state.hasLoadedOnce) {
          return _buildSkeletonRatings();
        }

        if (state.state == CubitStates.failure && state.ratings.isEmpty) {
          return _buildErrorSection(context);
        }

        return RefreshIndicator(
          onRefresh: () async => await context.read<RatingsCubit>().refresh(
            advisorId: widget.advisorId,
          ),
          child: Column(
            children: [
              if (!isMe) _buildAddRatingButton(context),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                child: Column(
                  children: [
                    _buildSummarySection(state),
                    Gap(20.h),
                    _buildRatingsList(context, state),
                  ],
                ),
              ),
              if (state.hasMore) _buildLoadMoreButton(context, state),
              Gap(20.h),
            ],
          ),
        );
      },
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
              context.tr('add_rating'),
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
    _reviewController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => IntCubit(0)), // For Rating
          BlocProvider(create: (_) => ToggleCubit(false)), // For submit loading
        ],
        child: Builder(
          builder: (innerContext) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Icon(Icons.close, size: 24.w),
                      ),
                      Text(
                        context.tr('rate_advisor'),
                        style: Styles.textStyle20Meduim.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      Gap(24.w),
                    ],
                  ),
                  Gap(25.h),
                  BlocBuilder<IntCubit, int>(
                    builder: (context, currentRating) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              context.read<IntCubit>().setValue(index + 1);
                            },
                            child: Icon(
                              Icons.star_rounded,
                              color: index < currentRating
                                  ? AppColors.kprimaryColor
                                  : AppColors.secondary100,
                              size: 56.w,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  BlocBuilder<IntCubit, int>(
                    builder: (context, currentRating) {
                      if (currentRating == 0) return const SizedBox.shrink();
                      return Column(
                        children: [
                          Gap(12.h),
                          Text(
                            '${context.tr('your_rating')}: $currentRating / 5',
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.primary500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Gap(24.h),
                  TextFormField(
                    controller: _reviewController,
                    maxLines: 4,
                    maxLength: 400,
                    decoration: InputDecoration(
                      labelText: context.tr('write_your_review'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  Gap(24.h),
                  BlocBuilder<ToggleCubit, bool>(
                    builder: (loadingContext, isSubmitting) {
                      if (isSubmitting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.kprimaryColor,
                          ),
                        );
                      }
                      return BlocBuilder<IntCubit, int>(
                        builder: (context, currentRating) {
                          return CustomBotton(
                            title: context.tr('send_rating'),
                            onPressed: currentRating == 0
                                ? null
                                : () async {
                                    loadingContext.read<ToggleCubit>().set(
                                      true,
                                    );
                                    await _submitRating(
                                      loadingContext,
                                      currentRating,
                                      _reviewController.text,
                                    );
                                  },
                            width: double.infinity,
                            height: 54.h,
                            backGroundcolor: currentRating == 0
                                ? Colors.transparent
                                : AppColors.secondary100,
                            useGradient: currentRating > 0,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitRating(
    BuildContext dialogContext,
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
        if (dialogContext.mounted) {
          Navigator.of(dialogContext, rootNavigator: true).pop();
        }

        showSafeSnackBar(
          context: context,
          text: response['message'] ?? context.tr('rate_app_success'),
          isSuccess: true,
        );

        if (mounted) {
          context.read<RatingsCubit>().fetchRatings(
            advisorId: widget.advisorId,
            loadMore: false,
            isSilent: false,
            forceRefresh: true,
          );
        }
      } else {
        if (dialogContext.mounted) {
          showSafeSnackBar(
            context: dialogContext,
            text: response['message'] ?? dialogContext.tr('rate_app_error'),
            isError: true,
          );
        }
      }
    } catch (e) {
      if (dialogContext.mounted) {
        showSafeSnackBar(
          context: dialogContext,
          text: dialogContext.tr('rate_app_error'),
          isError: true,
        );
      }
    } finally {
      if (dialogContext.mounted) {
        dialogContext.read<ToggleCubit>().set(false);
      }
    }
  }

  Widget _buildSkeletonRatings() {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
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

  Widget _buildErrorSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 100.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            context.tr('rate_app_error'),
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
          ),
          Gap(24.h),
          ElevatedButton(
            onPressed: () => context.read<RatingsCubit>().refresh(
              advisorId: widget.advisorId,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              context.tr('retry'),
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(RatingsState state) {
    final starsBreakdown = state.starsBreakdown;
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
                    '${state.totalRatings} ${context.tr('reviews')}',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Gap(8.h),
                ],
              ),
              Gap(24.w),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 5; i >= 1; i--)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
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
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
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
                            Text(
                              starsBreakdown[i] == 0
                                  ? ''
                                  : '${starsBreakdown[i]} ${context.tr('reviews')}',
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rating.user.name ?? context.tr('user'),
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
                    _ExpandableReviewText(text: rating.review),
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
      final parsedDate = DateFormat(
        'M/d/yyyy, hh:mm:ss a',
        'en',
      ).parse(dateString);

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
                onPressed: () => context.read<RatingsCubit>().fetchRatings(
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
                  context.tr('load_more'),
                  style: Styles.textStyle14Meduim.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
    );
  }
}

class _ExpandableReviewText extends StatelessWidget {
  final String text;
  const _ExpandableReviewText({required this.text});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ToggleCubit(false),
      child: BlocBuilder<ToggleCubit, bool>(
        builder: (context, isExpanded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final style = Styles.textStyle14.copyWith(
                color: AppColors.secondaryText,
                height: 1.6,
              );

              final span = TextSpan(text: text, style: style);
              final tp = TextPainter(
                text: span,
                maxLines: 3,
                textDirection: Directionality.of(context),
              );
              tp.layout(maxWidth: constraints.maxWidth);

              if (!tp.didExceedMaxLines) {
                return Text(
                  text,
                  style: style,
                  textAlign: TextAlign.right,
                  textDirection: Directionality.of(context),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.right,
                    textDirection: Directionality.of(context),
                    style: style,
                    maxLines: isExpanded ? null : 3,
                    overflow: isExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  InkWell(
                    onTap: () {
                      context.read<ToggleCubit>().toggle();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        isExpanded
                            ? context.tr('see_less')
                            : context.tr('see_more'),
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.kprimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
