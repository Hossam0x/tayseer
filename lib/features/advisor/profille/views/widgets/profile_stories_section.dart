import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/my_import.dart';

import 'package:tayseer/core/widgets/snack_bar_service.dart';

class ProfileStoriesSection extends StatelessWidget {
  final String? advisorId;
  const ProfileStoriesSection({super.key, this.advisorId});

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
      buildWhen: (previous, current) =>
          previous.storiesState != current.storiesState ||
          previous.storiesList != current.storiesList,
      builder: (context, state) {
        final isEmpty =
            (state.storiesState == CubitStates.success ||
                state.storiesState == CubitStates.initial) &&
            state.storiesList.isEmpty;

        if (isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

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
          onRetry: () => context.read<StoriesCubit>().fetchStories(
            isSpecial: true,
            advisorId: advisorId,
          ),
        );
      case CubitStates.success:
      case CubitStates.initial:
        if (state.storiesList.isEmpty) {
          return const SizedBox.shrink();
        }
        return _StoriesListView(
          stories: state.storiesList,
          advisorId: advisorId,
        );
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
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.stories.map(
            (userStory) => Padding(
              key: ValueKey('story_profile_${userStory.userId}'),
              padding: EdgeInsetsDirectional.only(
                end: context.responsiveWidth(14),
              ),
              child: _UserStoryItem(
                key: ValueKey(
                  'story_profile_${userStory.userId}_${userStory.allViewed}',
                ),
                userStoryModel: userStory,
              ),
            ),
          ),
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
  }
}

class _UserStoryItem extends StatelessWidget {
  final UserStoriesModel userStoryModel;

  const _UserStoryItem({super.key, required this.userStoryModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (newContext) => BlocProvider.value(
              value: context.read<StoriesCubit>(),
              child: StoryDetailsView(
                userStories: userStoryModel,
                heroTag: 'profile_story_${userStoryModel.userId}',
              ),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Hero(
            tag: 'profile_story_${userStoryModel.userId}',
            child: Container(
              width: context.responsiveWidth(76),
              height: context.responsiveWidth(76),
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: userStoryModel.allViewed
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
