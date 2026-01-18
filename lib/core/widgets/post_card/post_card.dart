import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_contect_text.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/core/widgets/post_card/real_video_player.dart';
import 'package:tayseer/core/widgets/post_card/user_info_header.dart';
import 'package:tayseer/core/widgets/post_card/post_images_grid.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/advisor/reels/views/reels_feed_view.dart';
import 'package:tayseer/my_import.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isDetailsView;
  final VideoPlayerController? sharedController;

  /// Bundled callbacks for post actions
  final PostCallbacks callbacks;

  /// Callback for navigating to post details
  final NavigateToDetailsCallback? onNavigateToDetails;

  const PostCard({
    super.key,
    required this.post,
    this.isDetailsView = false,
    this.sharedController,
    this.callbacks = const PostCallbacks(),
    this.onNavigateToDetails,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _activeController;

  @override
  void initState() {
    super.initState();
    _activeController = widget.sharedController;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Callbacks
  // ══════════════════════════════════════════════════════════════════════════

  void _navigateToDetails() {
    widget.onNavigateToDetails?.call(context, widget.post, _activeController);
  }

  void _handleReaction(ReactionType? type) {
    widget.callbacks.onReactionChanged?.call(widget.post.postId, type);
  }

  void _handleShare() {
    widget.callbacks.onShareTap?.call(widget.post.postId);
  }

  void _handleHashtag(String hashtag) {
    widget.callbacks.onHashtagTap?.call(hashtag);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final content = _CardContainer(
      isDetailsView: widget.isDetailsView,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repost Header
          if (widget.post.repostedBy != null) ...[
            _RepostHeader(repostedBy: widget.post.repostedBy!),
            Gap(context.responsiveHeight(8)),
          ],

          // User Info
          _PostUserHeader(
            post: widget.post,
            onMoreTap: widget.callbacks.onMoreTap,
          ),
          Gap(context.responsiveHeight(15)),

          // Content Text
          _PostContent(
            content: widget.post.content,
            onTap: _navigateToDetails,
            onHashtagTap: _handleHashtag,
          ),
          Gap(context.responsiveHeight(12)),

          // Media
          _PostMedia(
            post: widget.post,
            isDetailsView: widget.isDetailsView,
            sharedController: widget.sharedController,
            onControllerCreated: (c) => _activeController = c,
            callbacks: widget.callbacks,
          ),
          Gap(context.responsiveHeight(15)),

          // Stats
          PostStats(
            comments: widget.post.commentsCount,
            shares: widget.post.sharesCount,
            onTap: _navigateToDetails,
          ),
          Gap(context.responsiveHeight(8)),

          // Actions Row
          PostActionsRow(
            topReactions: widget.post.topReactions,
            likesCount: widget.post.likesCount,
            myReaction: widget.post.myReaction,
            isRepostedByMe: widget.post.isRepostedByMe,
            onCommentTap: _navigateToDetails,
            onReactionChanged: _handleReaction,
            onShareTap: _handleShare,
          ),
        ],
      ),
    );

    return widget.isDetailsView
        ? content
        : Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(22),
            ),
            child: content,
          );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Static Sub-Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _CardContainer extends StatelessWidget {
  final bool isDetailsView;
  final Widget child;

  const _CardContainer({required this.isDetailsView, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveHeight(14),
        horizontal: context.responsiveWidth(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            isDetailsView ? BorderRadius.zero : BorderRadius.circular(15.r),
        border: isDetailsView ? null : Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _RepostHeader extends StatelessWidget {
  final String repostedBy;

  const _RepostHeader({required this.repostedBy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Gap(context.responsiveWidth(8)),
        Icon(Icons.repeat_rounded, color: AppColors.kGreyB3, size: 18.sp),
        Gap(context.responsiveWidth(6)),
        Text(
          "$repostedBy ${context.tr('reposted')}",
          style: Styles.textStyle12SemiBold.copyWith(color: AppColors.kGreyB3),
        ),
      ],
    );
  }
}

class _PostUserHeader extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onMoreTap;

  const _PostUserHeader({required this.post, this.onMoreTap});

  @override
  Widget build(BuildContext context) {
    return UserInfoHeader(
      name: post.name,
      avatar: post.avatar,
      isVerified: post.isVerified,
      onMoreTap: onMoreTap ?? () {},
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              post.category,
              style: Styles.textStyle14.copyWith(
                color: AppColors.kprimaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Gap(context.responsiveWidth(4)),
          Text(
            " • ${post.timeAgo}",
            style: Styles.textStyle10.copyWith(color: HexColor("#99A1BE")),
          ),
          Gap(context.responsiveWidth(4)),
          Icon(Icons.public, color: AppColors.kGreyB3, size: 12.sp),
        ],
      ),
    );
  }
}

class _PostContent extends StatelessWidget {
  final String content;
  final VoidCallback onTap;
  final void Function(String) onHashtagTap;

  const _PostContent({
    required this.content,
    required this.onTap,
    required this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: PostContentText(
        text: content,
        style: Styles.textStyle14.copyWith(
          color: HexColor("#333333"),
          height: 1.5,
        ),
        hashtagStyle: Styles.textStyle14Bold.copyWith(color: Colors.blue),
        onHashtagTap: onHashtagTap,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Post Media
// ══════════════════════════════════════════════════════════════════════════════

class _PostMedia extends StatefulWidget {
  final PostModel post;
  final bool isDetailsView;
  final VideoPlayerController? sharedController;
  final void Function(VideoPlayerController) onControllerCreated;
  final PostCallbacks callbacks;

  const _PostMedia({
    required this.post,
    required this.isDetailsView,
    this.sharedController,
    required this.onControllerCreated,
    required this.callbacks,
  });

  @override
  State<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<_PostMedia> {
  VideoPlayerController? _activeController;

  @override
  void initState() {
    super.initState();
    _activeController = widget.sharedController;
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.post.contentType) {
      case PostContentType.post:
        return widget.post.images.isNotEmpty
            ? PostImagesGrid(
                isFromPostDetails: widget.isDetailsView,
                images: widget.post.images,
                postId: widget.post.postId,
                post: widget.post,
                callbacks: widget.callbacks,
              )
            : const SizedBox.shrink();

      case PostContentType.video:
        return RealVideoPlayer(
          postId: widget.post.postId,
          videoUrl: widget.post.videoUrl ?? '',
          isReel: false,
          videoController: _activeController,
          onControllerCreated: (controller) {
            _activeController = controller;
            widget.onControllerCreated(controller);
          },
        );

      case PostContentType.reel:
        return RealVideoPlayer(
          postId: widget.post.postId,
          videoUrl: widget.post.videoUrl ?? '',
          isReel: true,
          videoController: widget.sharedController ?? _activeController,
          onControllerCreated: (controller) {
            _activeController = controller;
            widget.onControllerCreated(controller);
          },
          onReelTap: _handleReelTap,
        );
    }
  }

  void _handleReelTap(VideoPlayerController controller) {
    if (widget.isDetailsView) {
      controller.value.isPlaying ? controller.pause() : _playVideo(controller);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReelsFeedView(
          post: widget.post,
          initialController: controller,
        ),
      ),
    ).then((_) {
      if (mounted && controller.value.isInitialized) {
        _playVideo(controller);
      }
    });
  }

  void _playVideo(VideoPlayerController controller) {
    VideoManager.instance.playVideo(widget.post.postId);
    controller.play();
  }
}