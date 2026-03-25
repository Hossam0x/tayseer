import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';

class PostItemWidget extends StatefulWidget {
  const PostItemWidget({
    super.key,
    required this.postId,
    required this.profileCubit,
    this.showGap = false,
  });

  final String postId;
  final ProfileCubit profileCubit;
  final bool showGap;

  @override
  State<PostItemWidget> createState() => _PostItemWidgetState();
}

class _PostItemWidgetState extends State<PostItemWidget> {
  late final Stream<PostModel?> _postStream;
  late final PostCallbacks _callbacks;

  @override
  void initState() {
    super.initState();
    _postStream = widget.profileCubit.stream
        .map(
          (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
        )
        .distinct();

    _callbacks = PostCallbacks(
      postUpdatesStream: _postStream,
      onReactionChanged: _onReaction,
      onShareTap: _onShare,
      onHashtagTap: _onHashtagTap,
      onSave: _onSave,
      onDelete: _onDelete,
      onHide: _hidePost,
      onBlock: _blockUser,
      onArchive: _archivePost,
      onEdit: _editPost,
    );
  }

  void _editPost(PostModel post) => context.pushNamed(
    AppRouter.kAddPostView,
    arguments: {"post": post, "isEdit": true},
  );

  void _archivePost(String postId) =>
      widget.profileCubit.archivePost(postId: postId);

  void _blockUser(String postId, String userId) =>
      widget.profileCubit.blockUser(visiblePostId: postId, advisorId: userId);

  void _hidePost(String postId) =>
      widget.profileCubit.toggleHidePost(postId: postId);

  void _onDelete(String postId) =>
      widget.profileCubit.deletePost(postId: postId);

  void _onSave(String postId) =>
      widget.profileCubit.toggleSavePost(postId: postId);

  void _onReaction(String id, ReactionType? type) =>
      widget.profileCubit.reactToPost(postId: id, reactionType: type);

  void _onShare(String id) => widget.profileCubit.toggleSharePost(postId: id);

  void _onHashtagTap(String hashtag) {
    final cleanHashtag = hashtag.startsWith('#')
        ? hashtag.substring(1)
        : hashtag;
    context.pushNamed(
      AppRouter.kAdvisorSearchView,
      arguments: {'query': cleanHashtag, 'tab': 'posts'},
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
          isFromProfile: true,
          heroPrefix: 'profile',
          post: post,
          cachedController: controller,
          callbacks: _callbacks,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocSelector<ProfileCubit, ProfileState, PostModel?>(
          selector: (state) =>
              state.posts.where((p) => p.postId == widget.postId).firstOrNull,
          builder: (context, post) {
            if (post == null) return const SizedBox.shrink();
            return PostCard(
              isFromProfile: true,
              heroPrefix: 'profile',
              post: post,
              callbacks: _callbacks,
              onNavigateToDetails: _onNavigateToDetails,
            );
          },
        ),
        if (widget.showGap) Gap(16.h),
      ],
    );
  }
}
