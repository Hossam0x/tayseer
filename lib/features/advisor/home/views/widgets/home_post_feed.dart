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
      child: BlocBuilder<HomeCubit, HomeState>(
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

          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index < posts.length) {
                return Column(
                  children: [
                    PostCard(post: posts[index]),
                    if (index < posts.length - 1)
                      Gap(context.responsiveHeight(12)),
                  ],
                );
              } else if (isLoadingMore) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: _PostCardShimmer()),
                );
              }
              return const SizedBox.shrink();
            }, childCount: posts.length + (isLoadingMore ? 1 : 0)),
          );
        },
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
