import 'package:tayseer/core/cubits/toggle_cubit.dart';
import 'package:tayseer/features/shared/settings/cubit/rating_cubit.dart';
import 'package:tayseer/my_import.dart';

/// Shared rate-app dialog used by both advisor and user settings.
/// [onSubmit] receives the selected rating (1–5) and returns a Future.
class SettingsRateDialog extends StatelessWidget {
  final Future<void> Function(int rating) onSubmit;

  const SettingsRateDialog({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RatingCubit()),
        BlocProvider(create: (_) => ToggleCubit(false)),
      ],
      child: Builder(
        builder: (ctx) => Dialog(
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
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 24.w),
                    ),
                    Text(
                      context.tr('rate_app'),
                      style: Styles.textStyle20Meduim.copyWith(
                        color: AppColors.primary500,
                      ),
                    ),
                    Gap(24.w),
                  ],
                ),
                Gap(25.h),
                // Stars
                BlocBuilder<RatingCubit, int>(
                  builder: (context, rating) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () =>
                            context.read<RatingCubit>().setRating(i + 1),
                        child: Icon(
                          Icons.star_rounded,
                          color: i < rating
                              ? AppColors.kprimaryColor
                              : AppColors.secondary100,
                          size: 56.w,
                        ),
                      );
                    }),
                  ),
                ),
                // Selected rating text
                BlocBuilder<RatingCubit, int>(
                  builder: (context, rating) {
                    if (rating == 0) return const SizedBox.shrink();
                    return Column(
                      children: [
                        Gap(12.h),
                        Text(
                          '${context.tr("rating")}: $rating / 5',
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Gap(24.h),
                Text(
                  context.tr('rate_app_message'),
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.secondary700,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(32.h),
                // Submit button
                BlocBuilder<ToggleCubit, bool>(
                  builder: (loadingCtx, isLoading) {
                    if (isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.kprimaryColor,
                        ),
                      );
                    }
                    return BlocBuilder<RatingCubit, int>(
                      builder: (ratingCtx, rating) => CustomBotton(
                        title: context.tr('send_rating'),
                        onPressed: rating == 0
                            ? null
                            : () async {
                                loadingCtx.read<ToggleCubit>().set(true);
                                try {
                                  await onSubmit(rating);
                                  if (loadingCtx.mounted) {
                                    Navigator.of(
                                      loadingCtx,
                                      rootNavigator: true,
                                    ).pop();
                                  }
                                } catch (_) {
                                  if (loadingCtx.mounted) {
                                    loadingCtx.read<ToggleCubit>().set(false);
                                  }
                                }
                              },
                        width: double.infinity,
                        height: 54.h,
                        useGradient: true,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
