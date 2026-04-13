import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/home/add_story_item.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/home/home_user_story_item.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_loading_shimmer.dart';
import 'package:tayseer/my_import.dart';

class HomeStoriesListView extends StatefulWidget {
  const HomeStoriesListView({super.key});

  @override
  State<HomeStoriesListView> createState() => _HomeStoriesListViewState();
}

class _HomeStoriesListViewState extends State<HomeStoriesListView> {
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
        isSpecial: false,
        context: context,
      );
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    return _scrollController.offset >=
        _scrollController.position.maxScrollExtent * 0.9;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StoriesCubit, StoriesState, String>(
      selector: (state) => state.storiesList.map((s) => s.userId).join(','),
      builder: (context, userIdsString) {
        final myUserId = kCurrentUserData?.id;
        final userIds = userIdsString.isEmpty
            ? <String>[]
            : userIdsString.split(',').where((id) => id != myUserId).toList();

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isAdvisor)
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: context.responsiveWidth(14),
                  ),
                  child: const AddStoryItem(),
                ),
              ...List.generate(userIds.length, (index) {
                final userId = userIds[index];
                return Padding(
                  key: ValueKey(userId),
                  padding: EdgeInsetsDirectional.only(
                    end: context.responsiveWidth(14),
                  ),
                  child: HomeUserStoryItem(
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
                  if (!state.isLoadingMore) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsetsDirectional.only(
                      end: context.responsiveWidth(14),
                    ),
                    child: const StoriesLoadingShimmer(count: 1),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
