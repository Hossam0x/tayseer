import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/view/a_search_view.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';

class AdvisorSearchPostItem extends StatelessWidget {
  final PostModel post;

  const AdvisorSearchPostItem({
    super.key,
    required this.post,
  });

  void _onNavigateToDetails(
    BuildContext ctx,
    PostModel post,
    VideoPlayerController? controller,
  ) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => PostDetailsView(
          isFromProfile: false,
          heroPrefix: 'search_advisor',
          post: post,
          cachedController: controller,
          callbacks: _buildCallbacks(ctx),
        ),
      ),
    );
  }

  PostCallbacks _buildCallbacks(BuildContext context) {
    final searchCubit = context.read<SearchCubit>();
    return PostCallbacks(
      onReactionChanged: (postId, type) {
        searchCubit.reactToPost(postId: postId, reactionType: type);
      },
      onShareTap: (postId) {
        searchCubit.toggleSharePost(postId: postId);
      },
      onSave: (postId) {
        searchCubit.toggleSavePost(postId: postId);
      },
      onDelete: (postId) {
        searchCubit.deletePost(postId: postId);
      },
      onArchive: (postId) {
        searchCubit.archivePost(postId: postId);
      },
      onHide: (postId) {
        searchCubit.toggleHidePost(postId: postId);
      },
      onBlock: (postId, advisorId) {
        searchCubit.blockUser(visiblePostId: postId, advisorId: advisorId);
      },
      onHashtagTap: (hashtag) {
        final cleanHashtag =
            hashtag.startsWith('#') ? hashtag.substring(1) : hashtag;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdvisorSearchView(
              initialQuery: cleanHashtag,
              initialTab: 'posts',
            ),
          ),
        );
      },
      onPollVote: (postId, choiceText) {
        searchCubit.voteInPoll(postId: postId, choiceText: choiceText);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PostCard(
      post: post,
      isFromProfile: false,
      heroPrefix: 'search_advisor',
      onNavigateToDetails: _onNavigateToDetails,
      callbacks: _buildCallbacks(context),
    );
  }
}
