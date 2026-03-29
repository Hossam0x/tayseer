import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_cubit.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/search_state.dart';
import 'package:tayseer/features/advisor/search/presentation/view/a_search_view.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';

class AdvisorSearchPostItem extends StatefulWidget {
  final String postId;

  const AdvisorSearchPostItem({super.key, required this.postId});

  @override
  State<AdvisorSearchPostItem> createState() => _AdvisorSearchPostItemState();
}

class _AdvisorSearchPostItemState extends State<AdvisorSearchPostItem>
    with AutomaticKeepAliveClientMixin {
  late final SearchCubit _searchCubit;
  late final Stream<PostModel?> _postStream;
  late final PostCallbacks _callbacks;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchCubit = context.read<SearchCubit>();
    _postStream = _searchCubit.stream
        .map(
          (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
        )
        .distinct();

    _callbacks = PostCallbacks(
      postUpdatesStream: _postStream,
      onReactionChanged: (postId, type) =>
          _searchCubit.reactToPost(postId: postId, reactionType: type),
      onShareTap: (postId) => _searchCubit.toggleSharePost(postId: postId),
      onSave: (postId) => _searchCubit.toggleSavePost(postId: postId),
      onDelete: (postId) => _searchCubit.deletePost(postId: postId),
      onArchive: (postId) => _searchCubit.archivePost(postId: postId),
      onHide: (postId) => _searchCubit.toggleHidePost(postId: postId),
      onBlock: (postId, advisorId) =>
          _searchCubit.blockUser(visiblePostId: postId, advisorId: advisorId),
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
      onPollVote: (postId, choiceText) =>
          _searchCubit.voteInPoll(postId: postId, choiceText: choiceText),
      onPostPopped: (updatedPost) =>
          _searchCubit.updatePostLocally(updatedPost),
    );
  }

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
          callbacks: _callbacks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocSelector<SearchCubit, SearchState, PostModel?>(
      selector: (state) =>
          state.posts.where((p) => p.postId == widget.postId).firstOrNull,
      builder: (context, post) {
        if (post == null) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: PostCard(
            post: post,
            isFromProfile: false,
            heroPrefix: 'search_advisor',
            onNavigateToDetails: _onNavigateToDetails,
            callbacks: _callbacks,
          ),
        );
      },
    );
  }
}
