import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/blocked_profile_placeholder.dart';
import 'package:tayseer/my_import.dart';
import 'stories/stories_sub_widgets.dart';

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
        final isMyProfile = advisorId == null;
        if (isMyProfile) {
          return previous.mySpecialStoriesState !=
                  current.mySpecialStoriesState ||
              previous.mySpecialStories != current.mySpecialStories;
        }
        return previous.advisorSpecialStoriesState !=
                current.advisorSpecialStoriesState ||
            previous.advisorSpecialStories != current.advisorSpecialStories ||
            previous.activeAdvisorId != current.activeAdvisorId;
      },
      builder: (context, state) {
        if (isBlocked) return const BlockedProfilePlaceholder(isSliver: true);

        final isMyProfile = advisorId == null;
        final currentState = isMyProfile
            ? state.mySpecialStoriesState
            : state.advisorSpecialStoriesState;
        final currentStories = isMyProfile
            ? state.mySpecialStories
            : state.advisorSpecialStories;
        final isOffline = getIt<ConnectivityCubit>().isOffline;
        final isCorrectAdvisor =
            isMyProfile || state.activeAdvisorId == advisorId;

        final isEmpty =
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
                child: const StoriesLoadingShimmer(),
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
    List<UserStoriesModel> stories,
    String errorMessage,
  ) {
    switch (currentState) {
      case CubitStates.loading:
        return const StoriesLoadingShimmer();
      case CubitStates.failure:
        return StoriesErrorWidget(
          message: errorMessage,
          onRetry: () => context.read<StoriesCubit>().fetchStories(
            isSpecial: true,
            advisorId: advisorId,
            context: context,
          ),
        );
      case CubitStates.success:
      case CubitStates.initial:
        if (stories.isEmpty) return const SizedBox.shrink();
        return StoriesListView(stories: stories, advisorId: advisorId);
    }
  }
}
