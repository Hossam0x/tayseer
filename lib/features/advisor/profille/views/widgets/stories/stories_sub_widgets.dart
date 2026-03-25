import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/my_import.dart';

class StoriesListView extends StatefulWidget {
  final List<UserStoriesModel> stories;
  final String? advisorId;

  const StoriesListView({super.key, required this.stories, this.advisorId});

  @override
  State<StoriesListView> createState() => _StoriesListViewState();
}

class _StoriesListViewState extends State<StoriesListView> {
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
    return _scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.9;
  }

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

    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (previous, current) {
        final isMyProfile = widget.advisorId == null;
        return isMyProfile
            ? previous.mySpecialIsLoadingMore != current.mySpecialIsLoadingMore
            : previous.advisorSpecialIsLoadingMore !=
                  current.advisorSpecialIsLoadingMore;
      },
      builder: (context, state) {
        final isMyProfile = widget.advisorId == null;
        final isLoadingMore = isMyProfile
            ? state.mySpecialIsLoadingMore
            : state.advisorSpecialIsLoadingMore;
        final itemCount = flatStories.length + (isLoadingMore ? 1 : 0);

        return SizedBox(
          height:
              context.responsiveWidth(76) +
              context.responsiveHeight(6) +
              context.responsiveHeight(16),
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (index == flatStories.length) {
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: context.responsiveWidth(14),
                  ),
                  child: const StoriesLoadingShimmer(count: 1),
                );
              }
              final parentUserStory = flatStories[index].key;
              final story = flatStories[index].value;
              return Padding(
                key: ValueKey('story_profile_${story.id}'),
                padding: EdgeInsetsDirectional.only(
                  end: context.responsiveWidth(14),
                ),
                child: SingleStoryItem(
                  key: ValueKey('story_profile_item_${story.id}'),
                  story: story,
                  parentUserStory: parentUserStory,
                  allStories: widget.stories,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class SingleStoryItem extends StatefulWidget {
  final StoryModel story;
  final UserStoriesModel parentUserStory;
  final List<UserStoriesModel> allStories;

  const SingleStoryItem({
    super.key,
    required this.story,
    required this.parentUserStory,
    required this.allStories,
  });

  @override
  State<SingleStoryItem> createState() => _SingleStoryItemState();
}

class _SingleStoryItemState extends State<SingleStoryItem> {
  String? _previousImageUrl;

  @override
  void didUpdateWidget(SingleStoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentUserStory.image != widget.parentUserStory.image) {
      _previousImageUrl = oldWidget.parentUserStory.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = 'profile_story_${widget.story.id}';

    return CustomClick(
      onTap: () => _openStory(context, heroTag),
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
                  color: widget.parentUserStory.allViewed
                      ? AppColors.kGreyB3
                      : AppColors.kprimaryColor,
                  width: 2.sp,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: widget.story.image,
                  fit: BoxFit.cover,
                  width: context.responsiveWidth(76),
                  height: context.responsiveWidth(76),
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  useOldImageOnUrlChange: true,
                  placeholder: (context, url) =>
                      _previousImageUrl != null && _previousImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: _previousImageUrl!,
                          fit: BoxFit.cover,
                          width: context.responsiveWidth(76),
                          height: context.responsiveWidth(76),
                          fadeInDuration: Duration.zero,
                          fadeOutDuration: Duration.zero,
                          errorWidget: (_, __, ___) =>
                              Container(color: AppColors.secondary200),
                        )
                      : Container(color: AppColors.secondary200),
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
              widget.parentUserStory.name,
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

  void _openStory(BuildContext context, String heroTag) {
    final flatList = <UserStoriesModel>[];
    for (final us in widget.allStories) {
      final sorted = [...us.stories]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      for (final s in sorted) {
        flatList.add(us.copyWith(stories: [s]));
      }
    }

    final initialIndex = flatList.indexWhere(
      (us) => us.stories.first.id == widget.story.id,
    );
    final safeIndex = initialIndex != -1 ? initialIndex : 0;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (newContext, animation, secondaryAnimation) =>
            BlocProvider.value(
              value: context.read<StoriesCubit>(),
              child: StoryDetailsView(
                usersStories: flatList,
                initialUserIndex: safeIndex,
                heroTag: heroTag,
              ),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class StoriesLoadingShimmer extends StatelessWidget {
  final int count;
  const StoriesLoadingShimmer({super.key, this.count = 5});

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

class StoriesErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const StoriesErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

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
