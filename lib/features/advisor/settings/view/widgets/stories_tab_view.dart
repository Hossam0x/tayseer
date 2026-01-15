import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/my_import.dart';

class StoriesTabView extends StatelessWidget {
  const StoriesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivedStoriesCubit, ArchivedStoriesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.kRedColor,
            ),
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
              return const SharedEmptyState(title: "لا توجد قصص مؤرشفة");
            }
            return _buildStoriesContent(context, state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSkeletonStories() {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        padding: EdgeInsets.all(20.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 10.h,
          childAspectRatio: 0.8,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(25.r),
            child: Container(
              color: Colors.grey.shade400,
              child: Stack(
                children: [
                  Positioned(
                    top: 20.h,
                    right: 20.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 20.w,
                            height: 16.h,
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
                ],
              ),
            ),
          );
        },
      ),
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
            errorMessage ?? 'حدث خطأ في تحميل القصص المؤرشفة',
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
              'إعادة المحاولة',
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
        child: GridView.builder(
          padding: EdgeInsets.all(20.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 0.8,
          ),
          itemCount: state.stories.length + (state.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.stories.length) {
              return _buildLoadMoreIndicator();
            }

            final story = state.stories[index];
            return _buildStoryItem(context, story);
          },
        ),
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, ArchiveStoryModel story) {
    final date = _parseDate(story.createdAt);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30.r),
      child: Stack(
        children: [
          // Story Background Image
          story.image != null
              ? Image.network(
                  story.image!,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return AppImage(
                      AssetsData.storyPlaceholder,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                )
              : AppImage(
                  AssetsData.storyPlaceholder,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
          // Date Badge (Matches UI image)
          Positioned(
            top: 20.h,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                children: [
                  Text(date.day.toString(), style: Styles.textStyle16),
                  Text(_getMonthName(date.month), style: Styles.textStyle12),
                ],
              ),
            ),
          ),
          // View Count
          Positioned(
            bottom: 8.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye, size: 14.sp, color: Colors.white),
                  Gap(4.w),
                  Text(
                    '${story.views}',
                    style: Styles.textStyle12.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Container(
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: AppColors.kprimaryColor),
    );
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
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
}
