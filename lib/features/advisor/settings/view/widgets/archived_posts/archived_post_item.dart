import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class ArchivedPostItem extends StatelessWidget {
  const ArchivedPostItem({super.key, required this.postId});

  final String postId;

  PostCallbacks _buildCallbacks(
    BuildContext context,
    ArchivedPostsCubit cubit,
  ) {
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
      onArchive: (id) => cubit.unarchivePost(id),
      onHide: (id) => cubit.toggleHidePost(postId: id),
      onBlock: (id, advisorId) =>
          cubit.blockUser(visiblePostId: id, advisorId: advisorId),
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
      onFollowTap: (advisorId) =>
          cubit.toggleFollowAdvisor(advisorId: advisorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ArchivedPostsCubit>();
    final callbacks = _buildCallbacks(context, cubit);

    return BlocSelector<ArchivedPostsCubit, ArchivedPostsState, PostModel?>(
      selector: (state) =>
          state.posts.where((p) => p.postId == postId).firstOrNull,
      builder: (context, post) {
        if (post == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: PostCard(
            isFromProfile: true,
            heroPrefix: 'archived_posts',
            isArchived: true,
            post: post,
            callbacks: callbacks,
            onNavigateToDetails: (ctx, p, controller, {initialImageIndex = 0}) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => PostDetailsView(
                    post: p,
                    isFromProfile: true,
                    isArchived: true,
                    heroPrefix: 'archived_posts',
                    cachedController: controller,
                    initialImageIndex: initialImageIndex,
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
