import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_contect_text.dart';
import 'package:tayseer/core/widgets/post_card/post_images_grid.dart';
import 'package:tayseer/core/widgets/post_card/post_options_bottom_sheet.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/core/widgets/post_card/real_video_player.dart';
import 'package:tayseer/core/widgets/post_card/user_info_header.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/services/deep_link_service.dart';
import 'package:tayseer/features/shared/event/view/widget/event_cart_item.dart';
import 'package:tayseer/features/shared/reels/views/reels_feed_view.dart';
import 'package:tayseer/core/widgets/post_card/post_poll_view.dart';
import 'package:tayseer/my_import.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isDetailsView;
  final VideoPlayerController? sharedController;
  final bool isFromProfile;
  final PostCallbacks callbacks;
  final String? heroPrefix;
  final bool isArchived;
  final NavigateToDetailsCallback? onNavigateToDetails;

  /// إخفاء صف الإحصائيات (كومنتات/شيرات) وصف الأكشن (إيك/كومنت/شير)
  final bool hideActions;

  /// إخفاء الوقت وزرار الـ options من الـ header
  final bool hideHeaderMeta;

  /// تحديد أقصى ارتفاع للميديا (صور/فيديو) — مفيد في الـ story canvas
  final double? mediaMaxHeight;

  const PostCard({
    super.key,
    required this.post,
    this.isDetailsView = false,
    this.sharedController,
    this.callbacks = const PostCallbacks(),
    this.onNavigateToDetails,
    required this.isFromProfile,
    this.heroPrefix,
    this.isArchived = false,
    this.hideActions = false,
    this.hideHeaderMeta = false,
    this.mediaMaxHeight,
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

  @override
  void dispose() {
    super.dispose();
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
    // ✅ يفتح sheet بخيارات الـ share فقط (2 أو 3 حسب نوع المستخدم)
    _showShareSheet(context);
  }

  void _showShareSheet(BuildContext context) {
    final postId = widget.post.postId;
    final isShared = widget.post.isRepostedByMe;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26.r),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 10.h),
                      width: 100.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: AppColors.secondary50,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ),
                  // ── Repost ──
                  _buildShareTile(
                    context,
                    icon: Icons.repeat_rounded,
                    text: isShared
                        ? context.tr(AppStrings.unshare)
                        : context.tr(AppStrings.share),
                    onTap: () {
                      Navigator.pop(context);
                      widget.callbacks.onShareTap?.call(postId);
                    },
                  ),
                  Divider(height: 1.h, color: AppColors.secondary50),
                  // ── Share as link ──
                  _buildShareTile(
                    context,
                    icon: Icons.link_rounded,
                    text: context.tr('share_as_link'),
                    onTap: () {
                      Navigator.pop(context);
                      DeepLinkService.sharePostDeepLink(
                        postId: postId,
                        context: context,
                      );
                    },
                  ),
                  // ── Share to story (advisor only) ──
                  if (isAdvisor) ...[
                    Divider(height: 1.h, color: AppColors.secondary50),
                    _buildShareTile(
                      context,
                      icon: Icons.auto_stories_rounded,
                      text: context.tr('share_to_story'),
                      onTap: () {
                        Navigator.pop(context);
                        widget.callbacks.onShareToStoryTap?.call(postId);
                      },
                    ),
                  ],
                  Gap(10.h),
                ],
              ),
            ),
            Gap(16.h),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26.r),
                ),
                child: Text(
                  context.tr(AppStrings.cancel),
                  textAlign: TextAlign.center,
                  style: Styles.textStyle16SemiBold.copyWith(
                    color: AppColors.secondary800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.secondary800),
            Gap(16.w),
            Text(
              text,
              style: Styles.textStyle16SemiBold.copyWith(
                color: AppColors.secondary800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleHashtag(String hashtag) {
    widget.callbacks.onHashtagTap?.call(hashtag);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Build
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (widget.post.isBlocked) {
      return _BlockedPostUI(post: widget.post);
    }
    if (widget.post.isHidden) {
      return _HiddenPostUI(
        onUndo: () => widget.callbacks.onHide?.call(widget.post.postId),
      );
    }

    final content = _CardContainer(
      isDetailsView: widget.isDetailsView,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.repostedBy != null) ...[
            _RepostHeader(repostedBy: widget.post.repostedBy!),
            Gap(context.responsiveHeight(8)),
          ],
          _PostUserHeader(
            isFromProfile: widget.isFromProfile,
            post: widget.post,
            hideHeaderMeta: widget.hideHeaderMeta,
            onFollowTap: widget.post.isMine
                ? null
                : () =>
                      widget.callbacks.onFollowTap?.call(widget.post.advisorId),
            onMoreTap: widget.hideHeaderMeta
                ? null
                : () => PostOptionsBottomSheet.show(
                    context,
                    post: widget.post,
                    isShared: widget.post.isRepostedByMe,
                    onDelete: () =>
                        widget.callbacks.onDelete?.call(widget.post.postId),
                    onArchive: () =>
                        widget.callbacks.onArchive?.call(widget.post.postId),
                    onShare: () =>
                        widget.callbacks.onShareTap?.call(widget.post.postId),
                    onShareToStory: () => widget.callbacks.onShareToStoryTap
                        ?.call(widget.post.postId),
                    onReport: () =>
                        widget.callbacks.onReport?.call(widget.post.postId),
                    onHide: () =>
                        widget.callbacks.onHide?.call(widget.post.postId),
                    onSave: () =>
                        widget.callbacks.onSave?.call(widget.post.postId),
                    onBlock: () => widget.callbacks.onBlock?.call(
                      widget.post.postId,
                      widget.post.advisorId,
                    ),
                    onEdit: (updatedPost) =>
                        widget.callbacks.onEdit?.call(updatedPost),
                    isArchived: widget.isArchived,
                  ),
          ),
          Gap(context.responsiveHeight(15)),
          _PostContent(
            content: widget.post.content,
            onTap: _navigateToDetails,
            onHashtagTap: _handleHashtag,
          ),
          Gap(context.responsiveHeight(12)),
          _PostMedia(
            isFromProfile: widget.isFromProfile,
            post: widget.post,
            isDetailsView: widget.isDetailsView,
            sharedController: widget.sharedController,
            onControllerCreated: (c) => _activeController = c,
            callbacks: widget.callbacks,
            heroPrefix: widget.heroPrefix,
            mediaMaxHeight: widget.mediaMaxHeight,
          ),
          if (!widget.hideActions) ...[
            Gap(context.responsiveHeight(15)),
            PostStats(
              comments: widget.post.commentsCount,
              shares: widget.post.sharesCount,
              onTap: _navigateToDetails,
            ),
            Gap(context.responsiveHeight(8)),
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

class _BlockedPostUI extends StatefulWidget {
  final PostModel post;

  const _BlockedPostUI({required this.post});

  @override
  State<_BlockedPostUI> createState() => _BlockedPostUIState();
}

class _BlockedPostUIState extends State<_BlockedPostUI> {
  bool _isClosed = false;

  void _onClose() => setState(() => _isClosed = true);

  @override
  Widget build(BuildContext context) {
    return _isClosed
        ? const SizedBox.shrink()
        : Container(
            margin: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(22),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(12),
              vertical: context.responsiveHeight(12),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFCF7FA),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary100, width: 1.sp),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: AppImage(
                                widget.post.avatar,
                                width: 28.w,
                                height: 28.w,
                                fit: BoxFit.cover,
                                isAvatar: true,
                              ),
                            ),
                          ),
                          Gap(10.w),
                          Flexible(
                            child: Text(
                              widget.post.name,
                              style: Styles.textStyle16Bold.copyWith(
                                color: const Color(0xFF0D1C52),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (widget.post.isVerified) ...[
                            Gap(4.w),
                            Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16.sp,
                            ),
                          ],
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _onClose,
                      child: Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Icon(
                          Icons.close_rounded,
                          color: const Color(0xFF757575),
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsetsGeometry.fromSTEB(34.w, 0, 0, 0),
                  child: Text(
                    context.tr(AppStrings.userBlockedMessage),
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary800,
                    ),
                  ),
                ),
                Gap(8.h),
              ],
            ),
          );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 👁️ Hidden Post UI
// ══════════════════════════════════════════════════════════════════════════════
class _HiddenPostUI extends StatelessWidget {
  final VoidCallback? onUndo;

  const _HiddenPostUI({this.onUndo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(22),
        vertical: context.responsiveHeight(8),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: context.responsiveWidth(12),
        vertical: context.responsiveHeight(16),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCF7FA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary100, width: 1.sp),
      ),
      child: Row(
        children: [
          Icon(
            Icons.layers_clear_outlined,
            color: AppColors.primary300,
            size: 24.sp,
          ),
          Gap(8.w),
          Expanded(
            child: Text(
              context.tr(AppStrings.postHiddenMessage),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
            ),
          ),
          Gap(8.w),
          GestureDetector(
            onTap: onUndo,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsiveWidth(20),
                vertical: context.responsiveHeight(8),
              ),
              decoration: BoxDecoration(
                color: AppColors.primary200,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primary400),
              ),
              child: Text(
                context.tr(AppStrings.cancel),
                style: Styles.textStyle14SemiBold.copyWith(
                  color: AppColors.primary400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ CHANGED: شيلنا clipBehavior: Clip.antiAlias
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
        borderRadius: isDetailsView
            ? BorderRadius.zero
            : BorderRadius.circular(15.r),
        border: isDetailsView ? null : Border.all(color: Colors.grey.shade200),
      ),
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
  final bool isFromProfile;
  final bool hideHeaderMeta;
  final VoidCallback? onFollowTap;

  const _PostUserHeader({
    required this.post,
    this.onMoreTap,
    required this.isFromProfile,
    this.hideHeaderMeta = false,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return UserInfoHeader(
      name: post.name,
      avatar: post.avatar,
      advisorId: post.advisorId,
      isVerified: post.isVerified,
      userType: post.userType,
      isMine: post.isMine,
      isFollowing: post.isFollowing,
      onFollowTap: onFollowTap,
      onMoreTap: hideHeaderMeta ? null : (onMoreTap ?? () {}),
      subtitle: hideHeaderMeta
          ? Text(
              post.category,
              style: Styles.textStyle14.copyWith(
                color: AppColors.kprimaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Row(
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
                  style: Styles.textStyle10.copyWith(
                    color: HexColor("#99A1BE"),
                  ),
                ),
                Gap(context.responsiveWidth(4)),
                Icon(Icons.public, color: AppColors.kGreyB3, size: 12.sp),
              ],
            ),
      isFromProfile: isFromProfile,
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
    return GestureDetector(
      onTap: onTap,
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

class _PostMedia extends StatefulWidget {
  final PostModel post;
  final bool isDetailsView;
  final VideoPlayerController? sharedController;
  final void Function(VideoPlayerController) onControllerCreated;
  final PostCallbacks callbacks;
  final bool isFromProfile;
  final String? heroPrefix;
  final double? mediaMaxHeight;

  const _PostMedia({
    required this.post,
    required this.isDetailsView,
    this.sharedController,
    required this.onControllerCreated,
    required this.callbacks,
    required this.isFromProfile,
    this.heroPrefix,
    this.mediaMaxHeight,
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
        if (widget.post.images.isEmpty) return const SizedBox.shrink();
        final imagesWidget = PostImagesGrid(
          isFromProfile: widget.isFromProfile,
          isFromPostDetails: widget.isDetailsView,
          images: widget.post.images,
          postId: widget.post.postId,
          post: widget.post,
          callbacks: widget.callbacks,
          heroPrefix: widget.heroPrefix,
        );
        return widget.mediaMaxHeight != null
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.mediaMaxHeight!),
                child: imagesWidget,
              )
            : imagesWidget;

      case PostContentType.event:
        return EventCardItem(
          key: ValueKey('event_${widget.post.postId}'),
          imageUrl: widget.post.event?.images.first ?? '',
          sessionTitle: widget.post.event?.title ?? '',
          location: widget.post.event?.location ?? '',
          advisorName: widget.post.event?.advisor ?? '',
          dateTime: widget.post.event?.date ?? '',
          price: widget.post.event?.priceAfterDiscount.toString() ?? '',
          oldPrice: widget.post.event?.priceBeforeDiscount.toString() ?? '',
          onTap: () {
            context.pushNamed(
              AppRouter.kEventDetailView,
              arguments: {'eventId': widget.post.event?.id},
            );
          },
        );

      case PostContentType.poll:
        return PostPollView(
          post: widget.post,
          onVote: (choiceText) =>
              widget.callbacks.onPollVote?.call(widget.post.postId, choiceText),
        );

      case PostContentType.reel:
        final videoWidget = RealVideoPlayer(
          postId: widget.post.postId,
          videoUrl: widget.post.videoUrl ?? '',
          videoData: widget.post.videoData,
          videoController: widget.sharedController ?? _activeController,
          onControllerCreated: (controller) {
            _activeController = controller;
            widget.onControllerCreated(controller);
          },
          onReelTap: _handleReelTap,
        );
        return widget.mediaMaxHeight != null
            ? ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.mediaMaxHeight!),
                child: videoWidget,
              )
            : videoWidget;
    }
  }

  void _handleReelTap(VideoPlayerController? controller) {
    if (widget.isDetailsView) {
      if (controller != null && controller.value.isInitialized) {
        controller.value.isPlaying
            ? controller.pause()
            : _playVideo(controller);
      }
      return;
    }

    if (controller != null && controller.value.isInitialized) {
      try {
        controller.pause();
      } catch (_) {}
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReelsFeedView(post: widget.post, initialController: controller),
      ),
    );
  }

  void _playVideo(VideoPlayerController controller) {
    VideoManager.instance.playVideo(widget.post.postId);
    controller.play();
  }
}
