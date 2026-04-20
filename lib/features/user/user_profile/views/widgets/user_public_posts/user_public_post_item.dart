import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_post_editor_view.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';

class UserPublicPostItem extends StatelessWidget {
  const UserPublicPostItem({
    super.key,
    required this.postId,
    required this.cubit,
    this.showGap = false,
  });

  final String postId;
  final UserPublicProfileCubit cubit;
  final bool showGap;

  PostCallbacks _buildCallbacks(BuildContext context) {
    final postStream = cubit.stream
        .map(
          (state) => state.posts.where((p) => p.postId == postId).firstOrNull,
        )
        .distinct();

    return PostCallbacks(
      postUpdatesStream: postStream,
      onReactionChanged: (id, type) =>
          cubit.reactToPost(postId: id, reactionType: type),
      onShareTap: (id) => cubit.toggleSharePost(postId: id),
      onShareToStoryTap: (id) {
        final post = cubit.state.posts.where((p) => p.postId == id).firstOrNull;
        if (post == null) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryPostEditorView(post: post),
            fullscreenDialog: true,
          ),
        );
      },
      onHashtagTap: (hashtag) {
        final clean = hashtag.startsWith('#') ? hashtag.substring(1) : hashtag;
        context.pushNamed(
          AppRouter.kAdvisorSearchView,
          arguments: {'query': clean, 'tab': 'posts'},
        );
      },
      onSave: (id) => cubit.toggleSavePost(postId: id),
      onDelete: (id) => cubit.deletePost(postId: id),
      onHide: (id) => cubit.toggleHidePost(postId: id),
      onBlock: (id, userId) =>
          cubit.blockUser(visiblePostId: id, userId: userId),
      onArchive: (id) => cubit.archivePost(postId: id),
      onEdit: (post) => context.pushNamed(
        AppRouter.kAddPostView,
        arguments: {"post": post, "isEdit": true},
      ),
      onPollVote: (id, choiceText) =>
          cubit.voteInPoll(postId: id, choiceText: choiceText),
      onCommented: (id, isAnonymous) =>
          cubit.markPostAsCommented(postId: id, isAnonymous: isAnonymous),
      onCommentCountDelta:
          ({required postId, required countDelta, isCommented, isAnonymous}) =>
              cubit.updateCommentCountByDelta(
                postId: postId,
                countDelta: countDelta,
                isCommented: isCommented,
                isAnonymous: isAnonymous,
              ),
      onCommentCountSync: ({required postId, required totalCount}) => cubit
          .syncCommentCountFromBackend(postId: postId, totalCount: totalCount),
      onFollowTap: (advisorId) =>
          cubit.toggleFollowAdvisor(advisorId: advisorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callbacks = _buildCallbacks(context);
    return Column(
      children: [
        BlocSelector<
          UserPublicProfileCubit,
          UserPublicProfileState,
          PostModel?
        >(
          selector: (state) =>
              state.posts.where((p) => p.postId == postId).firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              isFromProfile: true,
              heroPrefix: 'user_profile',
              post: post,
              callbacks: callbacks,
              onNavigateToDetails:
                  (ctx, p, controller, {initialImageIndex = 0}) {
                    Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => PostDetailsView(
                          isFromProfile: true,
                          heroPrefix: 'user_profile',
                          post: p,
                          cachedController: controller,
                          initialImageIndex: initialImageIndex,
                          callbacks: callbacks,
                        ),
                      ),
                    );
                  },
            );
          },
        ),
        if (showGap) Gap(1.h),
      ],
    );
  }
}
