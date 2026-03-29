import 'package:tayseer/core/cubits/int_cubit.dart';
import 'package:tayseer/core/cubits/toggle_cubit.dart';
import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_cubit.dart';
import 'package:tayseer/my_import.dart';

/// Shows the rating submission dialog.
/// [ratingsCubit] must be provided from the parent context before the dialog opens.
void showRateAdvisorDialog({
  required BuildContext context,
  required String advisorId,
  required TextEditingController reviewController,
}) {
  reviewController.clear();

  final ratingsCubit = context.read<RatingsCubit>();

  showDialog(
    context: context,
    builder: (dialogContext) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: ratingsCubit),
        BlocProvider(create: (_) => IntCubit(0)),
        BlocProvider(create: (_) => ToggleCubit(false)),
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
                _RateDialogHeader(dialogContext: dialogContext),
                Gap(25.h),
                const _StarSelector(),
                const _SelectedRatingText(),
                Gap(24.h),
                _ReviewTextField(controller: reviewController),
                Gap(24.h),
                _SubmitRatingButton(
                  advisorId: advisorId,
                  reviewController: reviewController,
                  dialogContext: dialogContext,
                  parentContext: context,
                  ratingsCubit: ratingsCubit,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _RateDialogHeader extends StatelessWidget {
  final BuildContext dialogContext;

  const _RateDialogHeader({required this.dialogContext});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _StarSelector extends StatelessWidget {
  const _StarSelector();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntCubit, int>(
      builder: (context, currentRating) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => context.read<IntCubit>().setValue(index + 1),
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
    );
  }
}

class _SelectedRatingText extends StatelessWidget {
  const _SelectedRatingText();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntCubit, int>(
      builder: (context, currentRating) {
        if (currentRating == 0) return const SizedBox.shrink();
        return Column(
          children: [
            Gap(12.h),
            Text(
              '${context.tr('your_rating')}: $currentRating / 5',
              style: Styles.textStyle14.copyWith(color: AppColors.primary500),
            ),
          ],
        );
      },
    );
  }
}

class _ReviewTextField extends StatelessWidget {
  final TextEditingController controller;

  const _ReviewTextField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      maxLength: 400,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: context.tr('write_your_review'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}

class _SubmitRatingButton extends StatelessWidget {
  final String advisorId;
  final TextEditingController reviewController;
  final BuildContext dialogContext;
  final BuildContext parentContext;
  final RatingsCubit ratingsCubit;

  const _SubmitRatingButton({
    required this.advisorId,
    required this.reviewController,
    required this.dialogContext,
    required this.parentContext,
    required this.ratingsCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToggleCubit, bool>(
      builder: (loadingContext, isSubmitting) {
        if (isSubmitting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.kprimaryColor),
          );
        }

        return BlocBuilder<IntCubit, int>(
          builder: (ratingContext, currentRating) {
            return CustomBotton(
              title: context.tr('send_rating'),
              onPressed: currentRating == 0
                  ? null
                  : () async {
                      loadingContext.read<ToggleCubit>().set(true);
                      await ratingsCubit.submitRating(
                        advisorId: advisorId,
                        rating: currentRating,
                        review: reviewController.text,
                        onSuccess: () {
                          if (dialogContext.mounted) {
                            Navigator.of(
                              dialogContext,
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
                          if (dialogContext.mounted) {
                            showSafeSnackBar(
                              context: dialogContext,
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
    );
  }
}
