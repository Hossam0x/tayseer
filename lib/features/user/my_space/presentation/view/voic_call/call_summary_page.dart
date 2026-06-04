import 'package:tayseer/core/cubits/int_cubit.dart';
import 'package:tayseer/core/cubits/toggle_cubit.dart';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_cubit.dart';
import 'package:tayseer/features/shared/profile/data/repositories/ratings_repository.dart';
import 'package:tayseer/my_import.dart';

/// شاشة ملخص المكالمة — تظهر بعد انتهاء الجلسة
class CallSummaryPage extends StatefulWidget {
  const CallSummaryPage({
    super.key,
    required this.advisorId,
    required this.advisorName,
    required this.advisorAvatarUrl,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserAvatarUrl,
    required this.durationSeconds,
    required this.endReason,
    required this.isUserSide,
    this.isAnonymous = false,
  });

  final String advisorId;
  final String advisorName;
  final String advisorAvatarUrl;
  final String currentUserId;
  final String currentUserName;
  final String currentUserAvatarUrl;
  final int durationSeconds;
  final String endReason;

  /// true = المستخدم العادي (يشوف التقييم والإبلاغ)
  /// false = الـ advisor (ما يشوفش التقييم)
  final bool isUserSide;

  /// true = anonymous session
  final bool isAnonymous;

  @override
  State<CallSummaryPage> createState() => _CallSummaryPageState();
}

class _CallSummaryPageState extends State<CallSummaryPage> {
  late final TextEditingController _reviewController;
  late final RatingsCubit _ratingsCubit;

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
    _ratingsCubit = RatingsCubit(getIt<RatingsRepository>());
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _ratingsCubit.close();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goHome(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.kWhiteColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      Gap(150.h),
                      _buildAvatar(),
                      Gap(16.h),
                      _buildAdvisorName(),
                      Gap(8.h),
                      _buildDuration(),
                      Gap(8.h),
                      _buildEndReason(),
                      Gap(40.h),
                      if (widget.isUserSide) ...[
                        _buildRateButton(context),
                        Gap(12.h),
                        _buildReportButton(context),
                      ],
                      Gap(24.h),
                      _buildDoneButton(context),
                      Gap(32.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.call_end_rounded, color: Colors.red, size: 24.sp),
          Gap(8.w),
          Text(
            context.tr('call_ended'),
            style: Styles.textStyle18SemiBold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // ✅ Correct mapping: User sees Advisor's photo, Advisor sees User's photo
    final displayAvatarUrl = widget.isUserSide
        ? widget
              .advisorAvatarUrl // User sees advisor's photo
        : widget.currentUserAvatarUrl; // Advisor sees user's photo

    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.kprimaryColor, width: 3),
      ),
      child: ClipOval(
        child: displayAvatarUrl.isNotEmpty
            ? Image.network(
                displayAvatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 50, color: Colors.grey),
              )
            : const Icon(Icons.person, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _buildAdvisorName() {
    // ✅ Correct mapping: User sees Advisor's name, Advisor sees User's name
    final displayName = widget.isUserSide
        ? widget
              .advisorName // User sees advisor's name
        : widget.currentUserName; // Advisor sees user's name

    return Text(
      displayName,
      style: Styles.textStyle20Meduim.copyWith(color: AppColors.secondary800),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDuration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer_outlined, size: 18.sp, color: AppColors.secondary400),
        Gap(4.w),
        Text(
          _formatDuration(widget.durationSeconds),
          style: Styles.textStyle16Meduim.copyWith(
            color: AppColors.secondary400,
          ),
        ),
      ],
    );
  }

  Widget _buildEndReason() {
    if (widget.endReason.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        widget.endReason,
        style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton.icon(
        onPressed: () => _showRateDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.kprimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: Icon(
          Icons.star_rounded,
          color: AppColors.kWhiteColor,
          size: 20.sp,
        ),
        label: Text(
          context.tr('add_rating'),
          style: Styles.textStyle16Meduim.copyWith(
            color: AppColors.kWhiteColor,
          ),
        ),
      ),
    );
  }

  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: OutlinedButton.icon(
        onPressed: () => _navigateToReport(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        icon: Icon(Icons.flag_outlined, color: Colors.red, size: 20.sp),
        label: Text(
          context.tr('report'),
          style: Styles.textStyle16Meduim.copyWith(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDoneButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: OutlinedButton(
        onPressed: () => _goHome(context),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.secondary200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          context.tr('done'),
          style: Styles.textStyle16Meduim.copyWith(
            color: AppColors.secondary600,
          ),
        ),
      ),
    );
  }

  // ─── Rating Dialog ────────────────────────────────────────────────────────
  void _showRateDialog(BuildContext parentCtx) {
    _reviewController.clear();
    showDialog(
      context: parentCtx,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _ratingsCubit),
          BlocProvider(create: (_) => IntCubit(0)),
          BlocProvider(create: (_) => ToggleCubit(false)),
        ],
        child: _RateDialog(
          advisorId: widget.advisorId,
          reviewController: _reviewController,
          parentContext: parentCtx,
          ratingsCubit: _ratingsCubit,
        ),
      ),
    );
  }

  void _navigateToReport(BuildContext context) {
    context.pushNamed(
      AppRouter.kReportsView,
      arguments: {'type': ReportType.user, 'id': widget.advisorId},
    );
  }

  void _goHome(BuildContext context) {
    // نرجع للخلف حتى نوصل للـ layout — بدل ما نعمل push جديد
    // ده بيحافظ على الـ LayoutCubit الموجود ويتجنب مشكلة IndexedStack
    Navigator.of(context).popUntil((route) {
      return route.settings.name == AppRouter.kUserLayoutView ||
          route.settings.name == AppRouter.kAdvisorLayoutView ||
          route.isFirst;
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _RateDialog — dialog التقييم مع الـ providers المطلوبة
// ─────────────────────────────────────────────────────────────────────────────

class _RateDialog extends StatelessWidget {
  const _RateDialog({
    required this.advisorId,
    required this.reviewController,
    required this.parentContext,
    required this.ratingsCubit,
  });

  final String advisorId;
  final TextEditingController reviewController;
  final BuildContext parentContext;
  final RatingsCubit ratingsCubit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
            // Stars
            BlocBuilder<IntCubit, int>(
              builder: (ctx, currentRating) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => ctx.read<IntCubit>().setValue(index + 1),
                    child: Icon(
                      Icons.star_rounded,
                      color: index < currentRating
                          ? AppColors.kprimaryColor
                          : AppColors.secondary100,
                      size: 56.w,
                    ),
                  );
                }),
              ),
            ),
            // Rating text
            BlocBuilder<IntCubit, int>(
              builder: (ctx, currentRating) {
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
            // Review text field
            TextFormField(
              controller: reviewController,
              maxLines: 4,
              maxLength: 400,
              decoration: InputDecoration(
                alignLabelWithHint: true,
                labelText: context.tr('write_your_review'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
            Gap(24.h),
            // Submit button
            BlocBuilder<ToggleCubit, bool>(
              builder: (loadingCtx, isSubmitting) {
                if (isSubmitting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.kprimaryColor,
                    ),
                  );
                }
                return BlocBuilder<IntCubit, int>(
                  builder: (ratingCtx, currentRating) {
                    return CustomBotton(
                      title: context.tr('send_rating'),
                      onPressed: currentRating == 0
                          ? null
                          : () async {
                              loadingCtx.read<ToggleCubit>().set(true);
                              await ratingsCubit.submitRating(
                                advisorId: advisorId,
                                rating: currentRating,
                                review: reviewController.text,
                                onSuccess: () {
                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pop();
                                  }
                                  if (parentContext.mounted) {
                                    showSafeSnackBar(
                                      context: parentContext,
                                      text: parentContext.tr(
                                        'advisor_rated_successfully',
                                      ),
                                      isSuccess: true,
                                    );
                                  }
                                },
                                onFailure: (error) {
                                  if (context.mounted) {
                                    showSafeSnackBar(
                                      context: context,
                                      text: error,
                                      isError: true,
                                    );
                                  }
                                },
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
    );
  }
}
