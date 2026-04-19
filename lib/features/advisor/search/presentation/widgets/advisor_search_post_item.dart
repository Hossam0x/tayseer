import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';
import 'package:tayseer/features/advisor/search/presentation/view/a_search_view.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';

class AdvisorSearchPostItem extends StatelessWidget {
  final String postId;

  const AdvisorSearchPostItem({super.key, required this.postId});

  PostCallbacks _buildCallbacks(BuildContext context, SearchCubit cubit) {
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
      onSave: (id) => cubit.toggleSavePost(postId: id),
      onDelete: (id) => cubit.deletePost(postId: id),
      onArchive: (id) => cubit.archivePost(postId: id),
      onHide: (id) => cubit.toggleHidePost(postId: id),
      onBlock: (id, advisorId) =>
          cubit.blockUser(visiblePostId: id, advisorId: advisorId),
      onEdit: (post) => cubit.updatePostLocally(post),
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
          cubit.toggleFollowAdvisorFromPost(advisorId: advisorId),
      onHashtagTap: (hashtag) {
        final clean = hashtag.startsWith('#') ? hashtag.substring(1) : hashtag;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AdvisorSearchView(initialQuery: clean, initialTab: 'posts'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SearchCubit>();
    final callbacks = _buildCallbacks(context, cubit);

    return BlocSelector<SearchCubit, SearchState, PostModel?>(
      selector: (state) =>
          state.posts.where((p) => p.postId == postId).firstOrNull,
      builder: (context, post) {
        if (post == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: PostCard(
            post: post,
            isFromProfile: false,
            heroPrefix: 'search_advisor',
            callbacks: callbacks,
            onNavigateToDetails: (ctx, p, controller, {initialImageIndex = 0}) {
              Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => PostDetailsView(
                    isFromProfile: false,
                    heroPrefix: 'search_advisor',
                    post: p,
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
