import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/single_story_item.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_loading_shimmer.dart';
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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
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

  void _prefetchIfNeeded(int index) {
    // Prefetch next page when reaching item 10 (half of the 20-item page)
    if (index == 9) {
      context.read<StoriesCubit>().fetchStories(
        loadMore: true,
        isSpecial: true,
        advisorId: widget.advisorId,
        context: context,
      );
    }
  }

  List<MapEntry<UserStoriesModel, StoryModel>> get _flatStories => [
    for (final userStory in widget.stories)
      for (final story in userStory.stories) MapEntry(userStory, story),
  ];

  Widget _buildStoryItem(
    int index,
    List<MapEntry<UserStoriesModel, StoryModel>> flatStories,
    bool isLoadingMore,
  ) {
    if (index == flatStories.length) {
      return Padding(
        padding: EdgeInsetsDirectional.only(end: context.responsiveWidth(14)),
        child: const StoriesLoadingShimmer(count: 1),
      );
    }
    // Prefetch next page when reaching item 10 (half of the 20-item page)
    _prefetchIfNeeded(index);
    final parentUserStory = flatStories[index].key;
    final story = flatStories[index].value;
    return Padding(
      key: ValueKey('story_profile_${story.id}'),
      padding: EdgeInsetsDirectional.only(end: context.responsiveWidth(14)),
      child: SingleStoryItem(
        key: ValueKey('story_profile_item_${story.id}'),
        story: story,
        parentUserStory: parentUserStory,
        allStories: widget.stories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flatStories = _flatStories;
    final isMyProfile = widget.advisorId == null;

    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (previous, current) => isMyProfile
          ? previous.mySpecialIsLoadingMore != current.mySpecialIsLoadingMore
          : previous.advisorSpecialIsLoadingMore !=
                current.advisorSpecialIsLoadingMore,
      builder: (context, state) {
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
              // Left padding for first item
              if (index == 0) {
                return Row(
                  children: [
                    Gap(context.responsiveWidth(22)),
                    _buildStoryItem(index, flatStories, isLoadingMore),
                  ],
                );
              }

              // Right padding for last item
              if (index == itemCount - 1) {
                return Row(
                  children: [
                    _buildStoryItem(index, flatStories, isLoadingMore),
                    Gap(context.responsiveWidth(22)),
                  ],
                );
              }

              return _buildStoryItem(index, flatStories, isLoadingMore);
            },
          ),
        );
      },
    );
  }
}
