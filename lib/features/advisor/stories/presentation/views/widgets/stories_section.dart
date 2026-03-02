import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/add_story_view.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (previous, current) =>
          previous.storiesState != current.storiesState ||
          previous.storiesList != current.storiesList,
      builder: (context, state) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.responsiveHeight(12),
              horizontal: context.responsiveWidth(30),
            ),
            child: _buildContent(context, state),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, StoriesState state) {
    switch (state.storiesState) {
      case CubitStates.loading:
        return const _StoriesLoadingShimmer();
      case CubitStates.failure:
        return _StoriesErrorWidget(
          message: state.storiesMessage,
          onRetry: () =>
              context.read<StoriesCubit>().fetchStories(context: context),
        );
      case CubitStates.success:
      case CubitStates.initial:
        return const _StoriesListView();
    }
  }
}

class _StoriesListView extends StatefulWidget {
  const _StoriesListView();

  @override
  State<_StoriesListView> createState() => _StoriesListViewState();
}

class _StoriesListViewState extends State<_StoriesListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<StoriesCubit>().fetchStories(
        loadMore: true,
        context: context,
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StoriesCubit, StoriesState, String>(
      selector: (state) => state.storiesList.map((s) => s.userId).join(','),
      builder: (context, userIdsString) {
        final userIds = userIdsString.isEmpty
            ? <String>[]
            : userIdsString.split(',');
        final myUserId = kCurrentUserData?.id;
        final listWithoutMe = userIds.where((id) => id != myUserId).toList();

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAdvisor) ...[
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: context.responsiveWidth(14),
                  ),
                  child: const _AddStoryItem(),
                ),
              ],
              ...List.generate(listWithoutMe.length, (index) {
                final userId = listWithoutMe[index];
                return Padding(
                  key: ValueKey(userId),
                  padding: EdgeInsetsDirectional.only(
                    end: context.responsiveWidth(14),
                  ),
                  child: _UserStoryItem(
                    key: ValueKey('story_$userId'),
                    userId: userId,
                    userIndex: index,
                  ),
                );
              }),
              BlocBuilder<StoriesCubit, StoriesState>(
                buildWhen: (previous, current) =>
                    previous.isLoadingMore != current.isLoadingMore,
                builder: (context, state) {
                  if (state.isLoadingMore) {
                    return Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: context.responsiveWidth(14),
                      ),
                      child: const _StoriesLoadingShimmer(count: 1),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserStoryItem extends StatelessWidget {
  final String userId;
  final int userIndex;

  const _UserStoryItem({
    super.key,
    required this.userId,
    required this.userIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StoriesCubit, StoriesState, UserStoriesModel?>(
      selector: (state) {
        try {
          return state.storiesList.firstWhere((s) => s.userId == userId);
        } catch (_) {
          return null;
        }
      },
      builder: (context, userStoryModel) {
        if (userStoryModel == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            if (isGuest) {
              CustomshowDialogWithImage(
                context,
                title: context.tr('joinUs'),
                supTitle: context.tr("guest_login_first"),
                icon: Icons.lock_person_outlined,
                iconColor: AppColors.kprimaryColor,
                bottonText: context.tr("login"),
                showCancelButton: true,
                cancelText: context.tr('skip'),
                onPressed: () {
                  CachNetwork.removeData(key: ktoken);
                  context.pushNamedAndRemoveUntil(
                    AppRouter.kRegisrationView,
                    predicate: (_) => false,
                  );
                },
                onCancel: () {},
              );
              return;
            }

            final myUserId = kCurrentUserData?.id;
            final allStories = context
                .read<StoriesCubit>()
                .state
                .storiesList
                .where((us) => us.userId != myUserId)
                .toList();

            final chronologicalUsersStories = allStories.map((us) {
              return us.copyWith(stories: us.stories.reversed.toList());
            }).toList();

            // Find the correct index in the filtered list
            final correctIndex = chronologicalUsersStories.indexWhere(
              (us) => us.userId == userId,
            );
            final safeIndex = correctIndex != -1 ? correctIndex : 0;

            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (newContext, animation, secondaryAnimation) =>
                    BlocProvider.value(
                      value: context.read<StoriesCubit>(),
                      child: StoryDetailsView(
                        usersStories: chronologicalUsersStories,
                        initialUserIndex: safeIndex,
                      ),
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
              ),
            );
          },
          child: Column(
            children: [
              Hero(
                tag: userStoryModel.userId,
                child: Container(
                  width: context.responsiveWidth(76),
                  height: context.responsiveWidth(76),
                  padding: EdgeInsets.all(3.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          (userStoryModel.allViewed ||
                              userStoryModel.isViewedByMe)
                          ? AppColors.kGreyB3
                          : AppColors.kprimaryColor,
                      width: 2.sp,
                    ),
                  ),
                  child: ClipOval(
                    child: AppImage(userStoryModel.image, fit: BoxFit.cover),
                  ),
                ),
              ),
              Gap(context.responsiveHeight(6)),
              SizedBox(
                width: context.responsiveWidth(76),
                child: Text(
                  userStoryModel.name,
                  textAlign: TextAlign.center,
                  style: Styles.textStyle10.copyWith(color: AppColors.kGreyB3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StoriesLoadingShimmer extends StatelessWidget {
  final int count;
  // ignore: unused_element_parameter
  const _StoriesLoadingShimmer({this.count = 5});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          count,
          (index) => Padding(
            padding: EdgeInsetsDirectional.only(
              end: context.responsiveWidth(14),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Container(
                    width: context.responsiveWidth(76),
                    height: context.responsiveWidth(76),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Gap(context.responsiveHeight(6)),
                  Container(
                    width: context.responsiveWidth(60),
                    height: context.responsiveHeight(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoriesErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StoriesErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message.isEmpty
                ? context.tr(AppStrings.errorLoadingStories)
                : message,
            style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
            textAlign: TextAlign.center,
          ),
          Gap(context.responsiveHeight(8)),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              context.tr(AppStrings.retry),
              style: Styles.textStyle12.copyWith(
                color: AppColors.kprimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStoryItem extends StatelessWidget {
  const _AddStoryItem();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, String?>(
      selector: (homeState) => homeState.homeInfo?.image,
      builder: (context, profileImage) {
        return BlocBuilder<StoriesCubit, StoriesState>(
          buildWhen: (previous, current) {
            final myUserId = kCurrentUserData?.id;
            final prevMyStory = previous.storiesList
                .where((s) => s.userId == myUserId)
                .firstOrNull;
            final currentMyStory = current.storiesList
                .where((s) => s.userId == myUserId)
                .firstOrNull;

            return previous.createStoryState != current.createStoryState ||
                previous.uploadProgress != current.uploadProgress ||
                prevMyStory != currentMyStory;
          },
          builder: (context, storyState) {
            final myUserId = kCurrentUserData?.id;
            final myStory = storyState.storiesList
                .where((s) => s.userId == myUserId)
                .firstOrNull;
            final isUploading =
                storyState.createStoryState == CubitStates.loading;

            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Upload Progress Ring
                    if (isUploading)
                      SizedBox(
                        width: context.responsiveWidth(76),
                        height: context.responsiveWidth(76),
                        child: CircularProgressIndicator(
                          value: storyState.uploadProgress > 0
                              ? storyState.uploadProgress
                              : null,
                          strokeWidth: 2.sp,
                          color: AppColors.kprimaryColor,
                          backgroundColor: AppColors.secondary200,
                        ),
                      ),

                    GestureDetector(
                      onTap: () {
                        if (isUploading) return;
                        if (myStory != null) {
                          // Open my story
                          final chronologicalUserStory = myStory.copyWith(
                            stories: myStory.stories.reversed.toList(),
                          );
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (newContext, animation, secondaryAnimation) =>
                                      BlocProvider.value(
                                        value: context.read<StoriesCubit>(),
                                        child: StoryDetailsView(
                                          usersStories: [
                                            chronologicalUserStory,
                                          ],
                                          initialUserIndex: 0,
                                        ),
                                      ),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                            ),
                          );
                        } else {
                          // Open add story
                          if (context.mounted) {
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
                        }
                      },
                      child: Hero(
                        tag: myStory != null
                            ? myStory.userId
                            : 'add_story_hero',
                        child: Container(
                          width: context.responsiveWidth(76),
                          height: context.responsiveWidth(76),
                          padding: myStory != null ? EdgeInsets.all(3.r) : null,
                          decoration: myStory != null
                              ? BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        (myStory.allViewed ||
                                            myStory.isViewedByMe)
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
                    ),

                    // Add Icon (Hidden when uploading)
                    if (!isUploading)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (context.mounted) {
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
                          },
                          child: Container(
                            width: context.responsiveWidth(24),
                            height: context.responsiveWidth(24),
                            decoration: BoxDecoration(
                              color: AppColors.kprimaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.sp,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),

                    // Percentage Text Overlay
                    if (isUploading)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${(storyState.uploadProgress * 100).toInt()}%',
                          style: Styles.textStyle10.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
