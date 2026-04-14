import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/saved_posts/saved_posts_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class SavedPostItem extends StatelessWidget {
  const SavedPostItem({required this.postId, required this.cubit, super.key});

  final String postId;
  final SavedPostsCubit cubit;

  PostCallbacks _buildCallbacks(BuildContext context) {
    final postStream = cubit.stream
        .map(
          (state) => state.posts.where((p) => p.postId == postId).firstOrNull,
        )
        .distinct();

    return PostCallbacks(
      postUpdatesStream: postStream,
      onReactionChanged: (id, reaction) =>
          cubit.reactToPost(postId: id, reactionType: reaction),
      onShareTap: (id) => cubit.toggleSharePost(postId: id),
      onSave: (id) => cubit.toggleSavePost(postId: id),
      onDelete: (id) => cubit.deletePost(postId: id),
      onArchive: (id) => cubit.archivePost(postId: id),
      onHide: (id) => cubit.toggleHidePost(postId: id),
      onBlock: (id, userId) =>
          cubit.blockUser(visiblePostId: id, advisorId: userId),
      onEdit: (post) => cubit.updatePostLocally(post),
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
      onPollVote: (id, choiceText) =>
          cubit.voteInPoll(postId: id, choiceText: choiceText),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callbacks = _buildCallbacks(context);
    return BlocSelector<SavedPostsCubit, SavedPostsState, PostModel?>(
      selector: (state) =>
          state.posts.where((p) => p.postId == postId).firstOrNull,
      builder: (context, post) {
        if (post == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: PostCard(
            isFromProfile: false,
            heroPrefix: 'saved_posts',
            post: post,
            callbacks: callbacks,
            onNavigateToDetails: (ctx, p, controller) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => PostDetailsView(
                    post: p,
                    isFromProfile: false,
                    heroPrefix: 'saved_posts',
                    cachedController: controller,
                    callbacks: callbacks,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
