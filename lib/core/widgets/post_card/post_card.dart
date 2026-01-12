import 'dart:developer';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_contect_text.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/core/widgets/post_card/real_video_player.dart';
import 'package:tayseer/core/widgets/post_card/user_info_header.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_images_grid.dart';
import 'package:tayseer/features/advisor/reels/views/reels_feed_view.dart';
import 'package:tayseer/my_import.dart';

/// PostCard widget - Generic reusable component for displaying posts
///
/// This widget is completely decoupled from any specific Cubit and can be used
/// anywhere in the app. All interactions are handled via callback functions.
class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isDetailsView;
  final VideoPlayerController? sharedController;

  /// Callback when user reacts to a post (like, love, etc.)
  final void Function(String postId, ReactionType? reactionType)?
  onReactionChanged;

  /// Callback when user shares/reposts a post
  final void Function(String postId)? onShareTap;

  /// Callback when user taps on comment button or post to view details
  final void Function(
    BuildContext context,
    PostModel post,
    VideoPlayerController? controller,
  )?
  onNavigateToDetails;

  /// Callback when user taps on hashtag
  final void Function(String hashtag)? onHashtagTap;

  /// Callback when user taps on "more" button in header
  final void Function()? onMoreTap;

  const PostCard({
    super.key,
    required this.post,
    this.isDetailsView = false,
    this.sharedController,
    this.onReactionChanged,
    this.onShareTap,
    this.onNavigateToDetails,
    this.onHashtagTap,
    this.onMoreTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

// ❌ تم حذف AutomaticKeepAliveClientMixin لحل مشكلة الذاكرة والشاشة السوداء
class _PostCardState extends State<PostCard> {
  VideoPlayerController? _activeController;

  @override
  void initState() {
    super.initState();
    if (widget.sharedController != null) {
      _activeController = widget.sharedController;
    }
  }

  void _navigateToDetails(BuildContext context) {
    if (widget.onNavigateToDetails != null) {
      widget.onNavigateToDetails!(context, widget.post, _activeController);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: EdgeInsets.symmetric(
        vertical: context.responsiveHeight(14),
        horizontal: context.responsiveWidth(10),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isDetailsView
            ? BorderRadius.zero
            : BorderRadius.circular(15.r),
        border: widget.isDetailsView
            ? null
            : Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.post.repostedBy != null) ...[
            _buildRepostHeader(context),
            Gap(context.responsiveHeight(8)),
          ],
          UserInfoHeader(
            name: widget.post.name,
            avatar: widget.post.avatar,
            isVerified: widget.post.isVerified,
            onMoreTap: widget.onMoreTap ?? () {},
            subtitle: Row(
              children: [
                Flexible(
                  child: Text(
                    widget.post.category,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(context.responsiveWidth(4)),
                Text(
                  " • ${widget.post.timeAgo}",
                  style: Styles.textStyle10.copyWith(
                    color: HexColor("#99A1BE"),
                  ),
                ),
                Gap(context.responsiveWidth(4)),
                Icon(Icons.public, color: AppColors.kGreyB3, size: 12.sp),
              ],
            ),
          ),
          Gap(context.responsiveHeight(15)),
          InkWell(
            onTap: () => _navigateToDetails(context),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            child: PostContentText(
              text: widget.post.content,
              style: Styles.textStyle14.copyWith(
                color: HexColor("#333333"),
                height: 1.5,
              ),
              hashtagStyle: Styles.textStyle14Bold.copyWith(color: Colors.blue),
              onHashtagTap:
                  widget.onHashtagTap ??
                  (hashtag) {
                    log("User tapped on: $hashtag");
                  },
            ),
          ),
          Gap(context.responsiveHeight(12)),
          _buildPostMedia(context),
          Gap(context.responsiveHeight(15)),
          PostStats(
            comments: widget.post.commentsCount,
            shares: widget.post.sharesCount,
            onTap: () => _navigateToDetails(context),
          ),
          Gap(context.responsiveHeight(8)),
          PostActionsRow(
            topReactions: widget.post.topReactions,
            likesCount: widget.post.likesCount,
            myReaction: widget.post.myReaction,
            isRepostedByMe: widget.post.isRepostedByMe,
            onCommentTap: () => _navigateToDetails(context),
            onReactionChanged: (react) {
              if (widget.onReactionChanged != null) {
                widget.onReactionChanged!(widget.post.postId, react);
              }
            },
            onShareTap: () {
              if (widget.onShareTap != null) {
                widget.onShareTap!(widget.post.postId);
              }
            },
          ),
        ],
      ),
    );

    if (!widget.isDetailsView) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.responsiveWidth(22)),
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildRepostHeader(BuildContext context) {
    return Row(
      children: [
        Gap(context.responsiveWidth(8)),
        Icon(Icons.repeat_rounded, color: AppColors.kGreyB3, size: 18.sp),
        Gap(context.responsiveWidth(6)),
        Text(
          "${widget.post.repostedBy} ${context.tr('reposted')}",
          style: Styles.textStyle12SemiBold.copyWith(color: AppColors.kGreyB3),
        ),
      ],
    );
  }

  Widget _buildPostMedia(BuildContext context) {
    switch (widget.post.contentType) {
      case PostContentType.post:
        return widget.post.images.isNotEmpty
            ? PostImagesGrid(
                isFromPostDetails: widget.isDetailsView,
                images: widget.post.images,
                postId: widget.post.postId,
                post: widget.post,
              )
            : const SizedBox.shrink();
      case PostContentType.video:
        return RealVideoPlayer(
          postId: widget.post.postId, // ✅ تم إضافة الـ ID
          videoUrl: widget.post.videoUrl ?? '',
          isReel: false,
          videoController: _activeController,
          onControllerCreated: (controller) {
            _activeController = controller;
          },
        );

      case PostContentType.reel:
        return RealVideoPlayer(
          postId: widget.post.postId, // ✅ تم إضافة الـ ID
          videoUrl: widget.post.videoUrl ?? '',
          isReel: true,
          videoController: widget.sharedController ?? _activeController,
          onControllerCreated: (controller) {
            _activeController = controller;
          },
          onReelTap: (controller) {
            if (widget.isDetailsView) {
              if (controller.value.isPlaying) {
                controller.pause();
              } else {
                // نبلغ المدير قبل التشغيل
                VideoManager.instance.playVideo(widget.post.postId);
                controller.play();
              }
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReelsFeedView(
                  post: widget.post,
                  initialController: controller,
                ),
              ),
            ).then((_) {
              if (mounted && controller.value.isInitialized) {
                VideoManager.instance.playVideo(widget.post.postId);
                controller.play();
              }
            });
          },
        );
    }
  }
}
