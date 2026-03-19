import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/blocked_profile_placeholder.dart';
import 'package:tayseer/my_import.dart';

class ProfileStoriesSection extends StatelessWidget {
  final String? advisorId;
  final bool isBlocked;
  const ProfileStoriesSection({
    super.key,
    this.advisorId,
    this.isBlocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StoriesCubit, StoriesState>(
      listenWhen: (previous, current) =>
          previous.createStoryState != current.createStoryState,
      listener: (context, state) {
        if (state.createStoryState == CubitStates.success) {
          showSafeSnackBar(
            context: context,
            text: state.createStoryMessage.isNotEmpty
                ? state.createStoryMessage
                : context.tr('story_published_success'),
            isSuccess: true,
          );
        } else if (state.createStoryState == CubitStates.failure) {
          showSafeSnackBar(
            context: context,
            text: state.createStoryMessage,
            isError: true,
          );
        }
      },
      buildWhen: (previous, current) {
        final bool isMyProfile = advisorId == null;
        if (isMyProfile) {
          return previous.mySpecialStoriesState !=
                  current.mySpecialStoriesState ||
              previous.mySpecialStories != current.mySpecialStories;
        } else {
          return previous.advisorSpecialStoriesState !=
                  current.advisorSpecialStoriesState ||
              previous.advisorSpecialStories != current.advisorSpecialStories ||
              previous.activeAdvisorId != current.activeAdvisorId;
        }
      },
      builder: (context, state) {
        if (isBlocked) {
          return const BlockedProfilePlaceholder(isSliver: true);
        }

        final bool isMyProfile = advisorId == null;
        final CubitStates currentState = isMyProfile
            ? state.mySpecialStoriesState
            : state.advisorSpecialStoriesState;
        final List<UserStoriesModel> currentStories = isMyProfile
            ? state.mySpecialStories
            : state.advisorSpecialStories;

        // ✅ Hide if offline and empty
        final isOffline = getIt<ConnectivityCubit>().isOffline;

        // For Advisor Profile, ensure we are looking at the right advisor's data
        final bool isCorrectAdvisor =
            isMyProfile || state.activeAdvisorId == advisorId;

        final bool isEmpty =
            isCorrectAdvisor &&
            (currentState == CubitStates.success ||
                currentState == CubitStates.initial) &&
            currentStories.isEmpty;

        if (!isCorrectAdvisor ||
            isEmpty ||
            (isOffline && currentStories.isEmpty)) {
          if (!isCorrectAdvisor && currentState == CubitStates.loading) {
            return SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.responsiveHeight(12),
                  horizontal: context.responsiveWidth(30),
                ),
                child: const _StoriesLoadingShimmer(),
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: context.responsiveHeight(12),
              horizontal: context.responsiveWidth(30),
            ),
            child: _buildContent(
              context,
              currentState,
              currentStories,
              state.storiesMessage,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    CubitStates currentState,
    List<UserStoriesModel> currentStories,
    String errorMessage,
  ) {
    switch (currentState) {
      case CubitStates.loading:
        return const _StoriesLoadingShimmer();
      case CubitStates.failure:
        return _StoriesErrorWidget(
          message: errorMessage,
          onRetry: () => context.read<StoriesCubit>().fetchStories(
            isSpecial: true,
            advisorId: advisorId,
            context: context,
          ),
        );
      case CubitStates.success:
      case CubitStates.initial:
        if (currentStories.isEmpty) {
          return const SizedBox.shrink();
        }
        return _StoriesListView(stories: currentStories, advisorId: advisorId);
    }
  }
}

class _StoriesListView extends StatefulWidget {
  final List<UserStoriesModel> stories;
  final String? advisorId;

  const _StoriesListView({required this.stories, this.advisorId});

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
        isSpecial: true,
        advisorId: widget.advisorId,
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

  // Flatten all individual stories with their parent UserStoriesModel
  // Stories come newest-first from API, so we keep that order as-is
  List<MapEntry<UserStoriesModel, StoryModel>> get _flatStories {
    final result = <MapEntry<UserStoriesModel, StoryModel>>[];
    for (final userStory in widget.stories) {
      for (final story in userStory.stories) {
        result.add(MapEntry(userStory, story));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final flatStories = _flatStories;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(flatStories.length, (index) {
            final parentUserStory = flatStories[index].key;
            final story = flatStories[index].value;
            return Padding(
              key: ValueKey('story_profile_${story.id}'),
              padding: EdgeInsetsDirectional.only(
                end: context.responsiveWidth(14),
              ),
              child: _SingleStoryItem(
                key: ValueKey('story_profile_item_${story.id}'),
                story: story,
                parentUserStory: parentUserStory,
                allStories: widget.stories,
              ),
            );
          }),
          BlocBuilder<StoriesCubit, StoriesState>(
            buildWhen: (previous, current) {
              final bool isMyProfile = widget.advisorId == null;
              if (isMyProfile) {
                return previous.mySpecialIsLoadingMore !=
                    current.mySpecialIsLoadingMore;
              } else {
                return previous.advisorSpecialIsLoadingMore !=
                    current.advisorSpecialIsLoadingMore;
              }
            },
            builder: (context, state) {
              final bool isMyProfile = widget.advisorId == null;
              final bool isLoadingMore = isMyProfile
                  ? state.mySpecialIsLoadingMore
                  : state.advisorSpecialIsLoadingMore;

              if (isLoadingMore) {
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
  }
}

class _SingleStoryItem extends StatelessWidget {
  final StoryModel story;
  final UserStoriesModel parentUserStory;
  final List<UserStoriesModel> allStories;

  const _SingleStoryItem({
    super.key,
    required this.story,
    required this.parentUserStory,
    required this.allStories,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = 'profile_story_${story.id}';

    return CustomClick(
      onTap: () {
        // Keep original API order (newest first) — no reverse
        final singleStoryUser = parentUserStory.copyWith(
          stories: parentUserStory.stories.toList(),
        );

        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (newContext, animation, secondaryAnimation) =>
                BlocProvider.value(
                  value: context.read<StoriesCubit>(),
                  child: StoryDetailsView(
                    usersStories: [singleStoryUser],
                    initialUserIndex: 0,
                    heroTag: heroTag,
                    initialStoryId: story.id,
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
            tag: heroTag,
            child: Container(
              width: context.responsiveWidth(76),
              height: context.responsiveWidth(76),
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (parentUserStory.allViewed)
                      ? AppColors.kGreyB3
                      : AppColors.kprimaryColor,
                  width: 2.sp,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: story.image,
                  fit: BoxFit.cover,
                  width: context.responsiveWidth(76),
                  height: context.responsiveWidth(76),
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholder: (context, url) =>
                      Container(color: AppColors.secondary200),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.secondary200,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.secondary400,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Gap(context.responsiveHeight(6)),
          SizedBox(
            width: context.responsiveWidth(76),
            child: Text(
              parentUserStory.name,
              textAlign: TextAlign.center,
              style: Styles.textStyle10.copyWith(color: AppColors.kGreyB3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoriesLoadingShimmer extends StatelessWidget {
  final int count;
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
              baseColor: AppColors.secondary100,
              highlightColor: AppColors.kWhiteColor.withOpacity(0.5),
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
