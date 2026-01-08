import 'package:tayseer/core/widgets/app_toast.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class HomePostFeed extends StatelessWidget {
  const HomePostFeed({super.key, required this.homeCubit});
  final HomeCubit homeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: homeCubit,
      child: BlocConsumer<HomeCubit, HomeState>(
        listenWhen: (previous, current) =>
            previous.shareActionState != current.shareActionState &&
            current.shareActionState != CubitStates.initial,
        listener: (context, state) {
          if (state.shareActionState == CubitStates.success) {
            if (state.isShareAdded == true) {
              AppToast.success(
                context,
                state.shareMessage ?? 'تمت المشاركة بنجاح',
              );
            } else {
              AppToast.info(context, state.shareMessage ?? 'تم إلغاء المشاركة');
            }
          } else if (state.shareActionState == CubitStates.failure) {
            AppToast.error(
              context,
              state.shareMessage ?? 'حدث خطأ أثناء المشاركة',
            );
          }
        },

        builder: (context, state) {
          if (state.postsState == CubitStates.loading && state.posts.isEmpty) {
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return const _PostCardShimmer();
              }, childCount: 3),
            );
          }

          if (state.postsState == CubitStates.failure && state.posts.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Text(
                  state.errorMessage ?? 'حدث خطأ ما',
                  style: Styles.textStyle16,
                ),
              ),
            );
          }

          final posts = state.posts;
          final isLoadingMore = state.isLoadingMore;

          // ملاحظة: يفضل أن يكون لديك متغير في الـ State اسمه hasReachedMax
          // للتأكد من أن البيانات انتهت فعلياً من السيرفر
          // final hasReachedMax = state.hasReachedMax;

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // عرض البوستات
                if (index < posts.length) {
                  return Column(
                    children: [
                      PostCard(post: posts[index]),
                      if (index < posts.length - 1)
                        Gap(context.responsiveHeight(12)),
                    ],
                  );
                }
                // نحن الآن في العنصر الأخير (ما بعد البوستات)
                else {
                  if (isLoadingMore) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: const Center(child: _PostCardShimmer()),
                    );
                  } else {
                    // عرض تصميم نهاية القائمة
                    return const _EndOfFeedIndicator();
                  }
                }
              },
              // قمنا بزيادة العدد 1 دائماً لحجز مكان إما للتحميل أو لرسالة النهاية
              childCount: posts.length + 1,
            ),
          );
        },
      ),
    );
  }
}

class _EndOfFeedIndicator extends StatelessWidget {
  const _EndOfFeedIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.postsEndIcon, height: 110.h),
          Text(
            "تم الوصول لنهاية المنشورات",
            style: Styles.textStyle14.copyWith(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
          Gap(4.h),
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          Gap(16.h),
        ],
      ),
    );
  }
}

class _PostCardShimmer extends StatelessWidget {
  const _PostCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 28.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Gap(context.responsiveWidth(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: context.responsiveWidth(120),
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Gap(context.responsiveHeight(6)),
                        Container(
                          width: context.responsiveWidth(180),
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gap(context.responsiveHeight(15)),
              // Content text
              Container(
                width: double.infinity,
                height: 14.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Gap(context.responsiveHeight(8)),
              Container(
                width: context.responsiveWidth(250),
                height: 14.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Gap(context.responsiveHeight(12)),
              // Image placeholder
              Container(
                width: double.infinity,
                height: context.responsiveHeight(206),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Gap(context.responsiveHeight(15)),
              // Stats
              Container(
                width: context.responsiveWidth(150),
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Gap(context.responsiveHeight(12)),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 6.w,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
