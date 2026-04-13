import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/add_story_view.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_navigation.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class AddStoryItem extends StatelessWidget {
  const AddStoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, String?>(
      selector: (homeState) => homeState.homeInfo?.image,
      builder: (context, profileImage) {
        return BlocBuilder<StoriesCubit, StoriesState>(
          buildWhen: (previous, current) =>
              previous.createStoryState != current.createStoryState ||
              previous.uploadProgress != current.uploadProgress ||
              previous.myStories != current.myStories ||
              previous.myStoriesState != current.myStoriesState,
          builder: (context, storyState) {
            final myStory = storyState.myStories;
            final isUploading =
                storyState.createStoryState == CubitStates.loading;

            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isUploading) _UploadProgressRing(storyState),
                    _AvatarButton(
                      myStory: myStory,
                      isUploading: isUploading,
                      profileImage: profileImage,
                    ),
                    if (!isUploading) _AddIconButton(),
                    if (isUploading) _UploadPercentageLabel(storyState),
                  ],
                ),
                Gap(context.responsiveHeight(6)),
                Text(
                  context.tr("your_story"),
                  style: Styles.textStyle10.copyWith(color: AppColors.kGreyB3),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UploadProgressRing extends StatelessWidget {
  final StoriesState state;
  const _UploadProgressRing(this.state);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.responsiveWidth(76),
      height: context.responsiveWidth(76),
      child: CircularProgressIndicator(
        value: state.uploadProgress > 0 ? state.uploadProgress : null,
        strokeWidth: 2.sp,
        color: AppColors.kprimaryColor,
        backgroundColor: AppColors.secondary200,
      ),
    );
  }
}

class _UploadPercentageLabel extends StatelessWidget {
  final StoriesState state;
  const _UploadPercentageLabel(this.state);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        '${(state.uploadProgress * 100).toInt()}%',
        style: Styles.textStyle10.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AddIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: CustomClick(
        onTap: () => _navigateToAddStory(context),
        child: Container(
          width: context.responsiveWidth(24),
          height: context.responsiveWidth(24),
          decoration: BoxDecoration(
            color: AppColors.kprimaryColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.sp),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 16.sp),
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  final UserStoriesModel? myStory;
  final bool isUploading;
  final String? profileImage;

  const _AvatarButton({
    required this.myStory,
    required this.isUploading,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomClick(
      onTap: () => _onTap(context),
      child: Hero(
        tag: myStory != null ? myStory!.userId : 'add_story_hero',
        child: Container(
          width: context.responsiveWidth(76),
          height: context.responsiveWidth(76),
          padding: myStory != null ? EdgeInsets.all(3.r) : null,
          decoration: myStory != null
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: myStory!.allViewed
                        ? AppColors.kGreyB3
                        : AppColors.kprimaryColor,
                    width: 2.sp,
                  ),
                )
              : null,
          child: MyProfileImage(
            width: context.responsiveWidth(
              isUploading || myStory != null ? 66 : 76,
            ),
            imageUrl: profileImage ?? kCurrentUserData?.image,
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (isUploading) return;

    if (myStory != null) {
      final storiesCubit = context.read<StoriesCubit>();
      storiesCubit.fetchMyStories(isSilent: true);

      final latestMyStories = storiesCubit.state.myStories ?? myStory!;
      final chronologicalUserStory = latestMyStories.copyWith(
        stories: latestMyStories.stories.reversed.toList(),
      );

      if (!context.mounted) return;
      await Future<void>.microtask(
        () => openStoryDetails(
          context: context,
          usersStories: [chronologicalUserStory],
          initialUserIndex: 0,
        ),
      );

      if (context.mounted) {
        context.read<StoriesCubit>().fetchMyStories(isSilent: true);
      }
    } else {
      _navigateToAddStory(context);
    }
  }
}

void _navigateToAddStory(BuildContext context) {
  if (!context.mounted) return;
  final storiesCubit = context.read<StoriesCubit>();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          BlocProvider.value(value: storiesCubit, child: const AddStoryView()),
    ),
  );
}
