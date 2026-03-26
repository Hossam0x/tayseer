import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/add_story_view.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/my_import.dart';

class ProfileStoryRing extends StatelessWidget {
  final String fallbackImageUrl;

  const ProfileStoryRing({super.key, required this.fallbackImageUrl});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (previous, current) =>
          previous.createStoryState != current.createStoryState ||
          previous.uploadProgress != current.uploadProgress ||
          previous.myStories != current.myStories ||
          previous.myStoriesState != current.myStoriesState,
      builder: (context, storyState) {
        final isUploading = storyState.createStoryState == CubitStates.loading;
        final myStories = storyState.myStories;
        final hasStories = myStories != null && myStories.stories.isNotEmpty;

        return CustomClick(
          onTap: isUploading
              ? null
              : () => _handleTap(context, storyState, myStories),
          onLongPress: () => _openFullScreenImage(context, fallbackImageUrl),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isUploading)
                SizedBox(
                  width: 92.w,
                  height: 92.w,
                  child: CircularProgressIndicator(
                    value: storyState.uploadProgress > 0
                        ? storyState.uploadProgress
                        : null,
                    strokeWidth: 4,
                    color: AppColors.kprimaryColor,
                    backgroundColor: AppColors.secondary200,
                  ),
                ),
              if (hasStories && !isUploading)
                Container(
                  width: 95.w,
                  height: 95.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: myStories.allViewed
                          ? AppColors.kGreyB3
                          : AppColors.kprimaryColor,
                      width: 3.sp,
                    ),
                  ),
                ),
              Padding(
                padding: hasStories && !isUploading
                    ? EdgeInsets.all(4.r)
                    : EdgeInsets.zero,
                child: Hero(
                  tag: 'profile_image_main',
                  child: MyProfileImage(
                    width: hasStories && !isUploading ? 79.w : 85.w,
                    imageUrl: fallbackImageUrl,
                  ),
                ),
              ),
              if (!isUploading)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: CustomClick(
                    onTap: () => _openAddStory(context),
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: AppColors.kprimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppImage(
                          width: 12.w,
                          AssetsData.icAdd,
                          color: AppColors.kWhiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              if (isUploading)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${(storyState.uploadProgress * 100).toInt()}%',
                    style: Styles.textStyle12.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _handleTap(
    BuildContext context,
    StoriesState storyState,
    UserStoriesModel? myStories,
  ) {
    if (myStories != null && myStories.stories.isNotEmpty) {
      _openMyStories(context, myStories);
    } else {
      _openAddStory(context);
    }
  }

  void _openMyStories(BuildContext context, UserStoriesModel myStories) async {
    final storiesCubit = context.read<StoriesCubit>();
    storiesCubit.fetchMyStories(isSilent: true);

    final latestMyStories = storiesCubit.state.myStories ?? myStories;
    final chronological = latestMyStories.copyWith(
      stories: latestMyStories.stories.reversed.toList(),
    );

    if (context.mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (newContext, animation, secondaryAnimation) =>
              BlocProvider.value(
                value: storiesCubit,
                child: StoryDetailsView(
                  usersStories: [chronological],
                  initialUserIndex: 0,
                ),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ).then((_) {
        if (context.mounted)
          context.read<StoriesCubit>().fetchMyStories(isSilent: true);
      });
    }
  }

  void _openAddStory(BuildContext context) {
    if (!context.mounted) return;
    final storiesCubit = context.read<StoriesCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: storiesCubit,
          child: const AddStoryView(),
        ),
      ),
    );
  }

  void _openFullScreenImage(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    FullScreenImageView.show(
      context,
      imageUrl: imageUrl,
      heroTag: 'profile_image_main',
    );
  }
}
