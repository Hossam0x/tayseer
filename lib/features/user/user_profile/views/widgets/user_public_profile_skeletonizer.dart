import 'package:tayseer/core/widgets/post_card/post_shimmer.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileViewSkeletonizer extends StatelessWidget {
  const UserPublicProfileViewSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        context.read<LanguageCubit>().state.languageCode == 'ar';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(40.h), // Top padding similar to back button space
                  // Header Row
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 90.w,
                        height: 90.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Gap(20.w),
                      // Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            Container(
                              width: 60.w,
                              height: 60.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(24.h),

                  // Bio Name
                  Container(
                    width: 150.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(8.h),
                  // Username
                  Container(
                    width: 100.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(12.h),

                  // Marriage Button Placeholder
                  Container(
                    width: 200.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  Gap(16.h),

                  // Description Lines
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(8.h),
                  Container(
                    width: 200.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(20.h),

                  // Tabs Header (Single 'Post' Tab simulation)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Transform.translate(
                        offset: Offset(isArabic ? 290.w : -290.w, 0),
                        child: Container(
                          width: 50.w,
                          height: 30.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ),
                      Gap(8.h),
                      const Divider(height: 1, color: Colors.white),
                    ],
                  ),
                  Gap(16.h),
                ],
              ),
            ),
          ),
        ),
        // Posts List Skeleton
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const PostCardShimmer(),
            childCount: 5,
          ),
        ),
      ],
    );
  }
}
