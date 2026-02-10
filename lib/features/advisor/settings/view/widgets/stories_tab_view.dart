import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/my_import.dart';

class StoriesTabView extends StatelessWidget {
  const StoriesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final SnackBarService snackBarService = SnackBarService();
    return BlocConsumer<ArchivedStoriesCubit, ArchivedStoriesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          snackBarService.showSnackBar(
            context: context,
            text: state.errorMessage!,
            isError: true,
          );
          context.read<ArchivedStoriesCubit>().clearError();
        }
      },
      builder: (context, state) {
        switch (state.state) {
          case CubitStates.loading:
            return _buildSkeletonStories();
          case CubitStates.failure:
            return _buildErrorStories(context, state.errorMessage);
          case CubitStates.success:
            if (state.stories.isEmpty) {
              return SharedEmptyState(title: context.tr('no_stories'));
            }
            return _buildStoriesContent(context, state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSkeletonStories() {
    return GridView.builder(
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 0.8,
      ),
      itemCount: 9, // 9 عناصر للـ skeleton
      itemBuilder: (context, index) {
        return Skeletonizer(
          enabled: true,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              color: Colors.grey.shade100,
            ),
            child: Stack(
              children: [
                // Skeleton للصورة
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.grey.shade300,
                  ),
                ),
                // Skeleton للتاريخ
                Positioned(
                  top: 20.h,
                  right: 20.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        Gap(2.h),
                        Container(
                          width: 40.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Skeleton للعلامة الخاصة (Special Badge)
                if (index % 3 == 0)
                  Positioned(
                    top: 20.h,
                    left: 20.w,
                    child: Container(
                      width: 24.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorStories(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            errorMessage ?? context.tr('error_loading_stories'),
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            onPressed: () => context.read<ArchivedStoriesCubit>().refresh(),
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

  Widget _buildStoriesContent(
    BuildContext context,
    ArchivedStoriesState state,
  ) {
    // Flatten the stories list to display individual stories in the grid
    final List<MapEntry<UserStoriesModel, StoryModel>> allStories = [];
    for (var userStory in state.stories) {
      for (var story in userStory.stories) {
        allStories.add(MapEntry(userStory, story));
      }
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (state.hasMore && !state.isLoadingMore) {
            context.read<ArchivedStoriesCubit>().fetchArchivedStories(
              loadMore: true,
            );
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => context.read<ArchivedStoriesCubit>().refresh(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(20.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == allStories.length) {
                    return _buildLoadMoreIndicator(state);
                  }

                  final parentUserStory = allStories[index].key;
                  final story = allStories[index].value;

                  return GestureDetector(
                    onTap: () {
                      // Reverse stories to chronological order (oldest first)
                      final chronologicalStories = parentUserStory
                          .stories
                          .reversed
                          .toList();

                      // Find the clicked story in the chronological list
                      final clickedStoryIndex = chronologicalStories.indexWhere(
                        (s) => s.id == story.id,
                      );

                      // Reorder to start from the clicked story
                      final List<StoryModel> reorderedStories;
                      if (clickedStoryIndex > 0) {
                        reorderedStories = [
                          ...chronologicalStories.sublist(clickedStoryIndex),
                          ...chronologicalStories.sublist(0, clickedStoryIndex),
                        ];
                      } else {
                        reorderedStories = chronologicalStories;
                      }

                      final tempUserStory = parentUserStory.copyWith(
                        stories: reorderedStories,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (newContext) => MultiBlocProvider(
                            providers: [
                              BlocProvider.value(value: getIt<StoriesCubit>()),
                              BlocProvider.value(
                                value: context.read<ArchivedStoriesCubit>(),
                              ),
                            ],
                            child: StoryDetailsView(
                              userStories: tempUserStory,
                              heroTag: 'archive_${story.id}',
                              isArchive: true,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'archive_${story.id}',
                      child: _buildStoryItem(context, story),
                    ),
                  );
                }, childCount: allStories.length + (state.hasMore ? 1 : 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, StoryModel story) {
    final date = story.createdAt;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Story Media (Image/Video)
          // Note: Current StoryModel mainly has image. If there's video, it might be in a different field or handled elsewhere.
          _buildStoryImage(story.image),

          // Content Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),

          // Date Badge
          Positioned(
            top: 15.h,
            right: 15.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    date.day.toString(),
                    style: Styles.textStyle16Meduim.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    _getMonthName(date.month),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Special Badge
          // if (story.isSpecial)
          //   Positioned(
          //     top: 20.h,
          //     left: 20.w,
          //     child: Container(
          //       padding: EdgeInsets.all(6.w),
          //       decoration: BoxDecoration(
          //         color: AppColors.kprimaryColor,
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.2),
          //             blurRadius: 4,
          //             offset: const Offset(0, 2),
          //           ),
          //         ],
          //       ),
          //       child: Icon(Icons.star, color: Colors.white, size: 16.sp),
          //     ),
          //   ),

          // Like Icon
          // Positioned(
          //   bottom: 15.h,
          //   left: 15.w,
          //   child: Row(
          //     children: [
          //       Icon(
          //         story.isLiked ? Icons.favorite : Icons.favorite_border,
          //         color: story.isLiked ? Colors.red : Colors.white,
          //         size: 18.sp,
          //       ),
          //       Gap(4.w),
          //       Text(
          //         '${story.likesCount}',
          //         style: Styles.textStyle12.copyWith(color: Colors.white),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildStoryImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        // Skeleton أثناء التحميل
        return Container(
          color: Colors.grey.shade300,
          child: Center(
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primary100,
      child: Center(
        child: Icon(Icons.photo, color: AppColors.primary300, size: 40.sp),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(ArchivedStoriesState state) {
    if (!state.hasMore) return SizedBox.shrink();

    if (state.isLoadingMore) {
      return Skeletonizer(
        enabled: true,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.r),
            color: Colors.grey.shade100,
          ),
        ),
      );
    }

    return Container(
      color: Colors.transparent,
      child: Center(
        child: Icon(
          Icons.arrow_downward,
          color: AppColors.primary300,
          size: 24.sp,
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  // String _formatDuration(double seconds) {
  //   final duration = Duration(seconds: seconds.toInt());
  //   final minutes = duration.inMinutes;
  //   final remainingSeconds = duration.inSeconds % 60;
  //   return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  // }
}
