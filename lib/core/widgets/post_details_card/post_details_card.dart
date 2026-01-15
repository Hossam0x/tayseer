import 'package:tayseer/core/widgets/comment_card/comment_card.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/home/model/comment_model.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

/// PostDetailsCard - Reusable component for displaying post with comments
///
/// Completely decoupled from any specific Cubit.
/// Use [PostDetailsWrapper] to connect it to a Cubit.
///
/// Performance Features:
/// - Separated post and comments sections
/// - Comments list uses ID-based selector for granular rebuilds
/// - Each comment rebuilds independently
class PostDetailsCard extends StatelessWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final ScrollController? scrollController;

  // Post Callbacks
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;
  final void Function(String postId)? onShareTap;
  final void Function(String hashtag)? onHashtagTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onCommentTap;

  // Comments Data
  final List<CommentModel> comments;
  final bool isLoadingComments;
  final bool hasMoreComments;
  final bool isLoadingMore;
  final String? commentsError;

  // Comments Callbacks
  final VoidCallback? onLoadMore;
  final VoidCallback? onRetry;
  final void Function(CommentModel comment, bool isReply)? onLikeComment;
  final void Function(String commentId)? onReplyTap;
  final void Function(String commentId)? onEditTap;
  final VoidCallback? onCancelEdit;
  final VoidCallback? onCancelReply;
  final void Function(String commentId, String content, bool isReply)?
  onSaveEdit;
  final void Function(String commentId, String text)? onSendReply;
  final void Function(String commentId)? onLoadReplies;

  // State for edit/reply
  final String? editingCommentId;
  final String? activeReplyId;
  final bool isEditLoading;
  final bool isReplyLoading;

  const PostDetailsCard({
    super.key,
    required this.post,
    this.cachedController,
    this.scrollController,
    // Post Callbacks
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
    this.onMoreTap,
    this.onCommentTap,
    // Comments Data
    this.comments = const [],
    this.isLoadingComments = false,
    this.hasMoreComments = false,
    this.isLoadingMore = false,
    this.commentsError,
    // Comments Callbacks
    this.onLoadMore,
    this.onRetry,
    this.onLikeComment,
    this.onReplyTap,
    this.onEditTap,
    this.onCancelEdit,
    this.onCancelReply,
    this.onSaveEdit,
    this.onSendReply,
    this.onLoadReplies,
    // State
    this.editingCommentId,
    this.activeReplyId,
    this.isEditLoading = false,
    this.isReplyLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Post Section
        _PostSection(
          post: post,
          cachedController: cachedController,
          onReactionChanged: onReactionChanged,
          onShareTap: onShareTap,
          onHashtagTap: onHashtagTap,
          onMoreTap: onMoreTap,
          onCommentTap: onCommentTap,
        ),

        SliverToBoxAdapter(child: Gap(10.h)),

        // Comments Section
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          sliver: _buildCommentsSection(context),
        ),

        SliverToBoxAdapter(child: Gap(20.h)),
      ],
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    // Loading
    if (isLoadingComments && comments.isEmpty) {
      return const _CommentsShimmer();
    }

    // Error
    if (commentsError != null && comments.isEmpty) {
      return SliverToBoxAdapter(
        child: _ErrorState(message: commentsError!, onRetry: onRetry),
      );
    }

    // Empty
    if (comments.isEmpty) {
      return const SliverToBoxAdapter(child: _EmptyCommentsState());
    }

    // Comments List
    return _CommentsList(
      comments: comments,
      hasMore: hasMoreComments,
      isLoadingMore: isLoadingMore,
      onLoadMore: onLoadMore,
      editingCommentId: editingCommentId,
      activeReplyId: activeReplyId,
      isEditLoading: isEditLoading,
      isReplyLoading: isReplyLoading,
      onLikeComment: onLikeComment,
      onReplyTap: onReplyTap,
      onEditTap: onEditTap,
      onCancelEdit: onCancelEdit,
      onCancelReply: onCancelReply,
      onSaveEdit: onSaveEdit,
      onSendReply: onSendReply,
      onLoadReplies: onLoadReplies,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Post Section
// ══════════════════════════════════════════════════════════════════════════════

class _PostSection extends StatelessWidget {
  final PostModel post;
  final VideoPlayerController? cachedController;
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;
  final void Function(String postId)? onShareTap;
  final void Function(String hashtag)? onHashtagTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onCommentTap;

  const _PostSection({
    required this.post,
    this.cachedController,
    this.onReactionChanged,
    this.onShareTap,
    this.onHashtagTap,
    this.onMoreTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: PostCard(
        post: post,
        isDetailsView: true,
        sharedController: cachedController,
        onReactionChanged: onReactionChanged,
        onShareTap: onShareTap,
        onNavigateToDetails: (_, __, ___) => onCommentTap?.call(),
        onHashtagTap: onHashtagTap,
        onMoreTap: onMoreTap,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Comments List (Optimized)
// ══════════════════════════════════════════════════════════════════════════════

class _CommentsList extends StatelessWidget {
  final List<CommentModel> comments;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final String? editingCommentId;
  final String? activeReplyId;
  final bool isEditLoading;
  final bool isReplyLoading;
  final void Function(CommentModel comment, bool isReply)? onLikeComment;
  final void Function(String commentId)? onReplyTap;
  final void Function(String commentId)? onEditTap;
  final VoidCallback? onCancelEdit;
  final VoidCallback? onCancelReply;
  final void Function(String commentId, String content, bool isReply)?
  onSaveEdit;
  final void Function(String commentId, String text)? onSendReply;
  final void Function(String commentId)? onLoadReplies;

  const _CommentsList({
    required this.comments,
    required this.hasMore,
    required this.isLoadingMore,
    this.onLoadMore,
    this.editingCommentId,
    this.activeReplyId,
    this.isEditLoading = false,
    this.isReplyLoading = false,
    this.onLikeComment,
    this.onReplyTap,
    this.onEditTap,
    this.onCancelEdit,
    this.onCancelReply,
    this.onSaveEdit,
    this.onSendReply,
    this.onLoadReplies,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // Load More / Pagination
        if (index == comments.length) {
          return _buildPaginationWidget();
        }

        final comment = comments[index];
        final isLast = index == comments.length - 1;

        return Column(
          children: [
            _CommentItem(
              key: ValueKey(comment.id),
              comment: comment,
              isEditing: editingCommentId == comment.id,
              isReplying: activeReplyId == comment.id,
              isEditLoading: editingCommentId == comment.id && isEditLoading,
              isReplyLoading: activeReplyId == comment.id && isReplyLoading,
              onLikeTap: () => onLikeComment?.call(comment, false),
              onReplyTap: () => onReplyTap?.call(comment.id),
              onEditTap: () => onEditTap?.call(comment.id),
              onCancelEdit: onCancelEdit,
              onCancelReply: onCancelReply,
              onSaveEdit: (content) =>
                  onSaveEdit?.call(comment.id, content, false),
              onSendReply: (text) => onSendReply?.call(comment.id, text),
              onLoadReplies: () => onLoadReplies?.call(comment.id),
              // Pass callbacks for replies
              onLikeReply: (reply) => onLikeComment?.call(reply, true),
              onSaveReplyEdit: (replyId, content) =>
                  onSaveEdit?.call(replyId, content, true),
            ),
            if (!isLast)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Divider(color: Colors.grey.shade200, height: 1.h),
              ),
          ],
        );
      }, childCount: comments.length + (hasMore || isLoadingMore ? 1 : 0)),
    );
  }

  Widget _buildPaginationWidget() {
    if (isLoadingMore) {
      return Padding(
        padding: EdgeInsets.all(16.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasMore) {
      return TextButton(
        onPressed: onLoadMore,
        child: Text('تحميل المزيد', style: Styles.textStyle14SemiBold),
      );
    }

    return const SizedBox.shrink();
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Comment Item
// ══════════════════════════════════════════════════════════════════════════════

class _CommentItem extends StatefulWidget {
  final CommentModel comment;
  final bool isEditing;
  final bool isReplying;
  final bool isEditLoading;
  final bool isReplyLoading;
  final VoidCallback? onLikeTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onCancelEdit;
  final VoidCallback? onCancelReply;
  final void Function(String content)? onSaveEdit;
  final void Function(String text)? onSendReply;
  final VoidCallback? onLoadReplies;
  final void Function(CommentModel reply)? onLikeReply;
  final void Function(String replyId, String content)? onSaveReplyEdit;

  const _CommentItem({
    super.key,
    required this.comment,
    this.isEditing = false,
    this.isReplying = false,
    this.isEditLoading = false,
    this.isReplyLoading = false,
    this.onLikeTap,
    this.onReplyTap,
    this.onEditTap,
    this.onCancelEdit,
    this.onCancelReply,
    this.onSaveEdit,
    this.onSendReply,
    this.onLoadReplies,
    this.onLikeReply,
    this.onSaveReplyEdit,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  CommentCard? _cachedWidget;
  CommentModel? _lastComment;
  bool? _lastIsEditing;
  bool? _lastIsReplying;
  bool? _lastIsEditLoading;
  bool? _lastIsReplyLoading;
  bool? _lastIsLoadingReplies;

  @override
  Widget build(BuildContext context) {
    final shouldRebuild =
        _cachedWidget == null ||
        widget.comment != _lastComment || // Relies on Equatable or Ref equality
        widget.isEditing != _lastIsEditing ||
        widget.isReplying != _lastIsReplying ||
        widget.isEditLoading != _lastIsEditLoading ||
        widget.isReplyLoading != _lastIsReplyLoading ||
        widget.comment.isLoadingReplies != _lastIsLoadingReplies;

    if (shouldRebuild) {
      _lastComment = widget.comment;
      _lastIsEditing = widget.isEditing;
      _lastIsReplying = widget.isReplying;
      _lastIsEditLoading = widget.isEditLoading;
      _lastIsReplyLoading = widget.isReplyLoading;
      _lastIsLoadingReplies = widget.comment.isLoadingReplies;

      _cachedWidget = CommentCard(
        comment: widget.comment,
        isReply: false,
        isEditing: widget.isEditing,
        isReplying: widget.isReplying,
        isEditLoading: widget.isEditLoading,
        isReplyLoading: widget.isReplyLoading,
        isLoadingReplies: widget.comment.isLoadingReplies,
        onLikeTap: widget.onLikeTap,
        onReplyTap: widget.onReplyTap,
        onEditTap: widget.onEditTap,
        onCancelEdit: widget.onCancelEdit,
        onCancelReply: widget.onCancelReply,
        onSaveEdit: widget.onSaveEdit,
        onSendReply: widget.onSendReply,
        onLoadReplies: widget.onLoadReplies,
        onLikeReply: widget.onLikeReply,
        // Replies logic inside CommentCard usually handles sub-items
        // If CommentCard iterates replies, it might rebuild them.
        // But preventing the root CommentCard from rebuilding is the big win.
      );
    }

    return _cachedWidget!;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// State Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _EmptyCommentsState extends StatelessWidget {
  const _EmptyCommentsState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Gap(16.h),
        AppImage(AssetsData.noCommentsIcon, height: 130.h),
        Gap(20.h),
        Text(
          context.tr(AppStrings.noComments),
          style: Styles.textStyle14.copyWith(color: AppColors.kGreyB3),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
          Gap(10.h),
          TextButton(
            onPressed: onRetry,
            child: Text(
              context.tr(AppStrings.retry),
              style: Styles.textStyle14SemiBold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentsShimmer extends StatelessWidget {
  const _CommentsShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => const _CommentShimmerItem(),
        childCount: 3,
      ),
    );
  }
}

class _CommentShimmerItem extends StatelessWidget {
  const _CommentShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            Gap(10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(8.h),
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(6.h),
                  Container(
                    width: 200.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
