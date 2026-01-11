import 'dart:developer';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_contect_text.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/core/widgets/post_card/real_video_player.dart';
import 'package:tayseer/core/widgets/post_card/user_info_header.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_images_grid.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/reels/views/reels_feed_view.dart';
import 'package:tayseer/features/advisor/home/views/post_details_view.dart';
import 'package:tayseer/features/advisor/home/view_model/post_details_cubit/post_details_cubit.dart';
import 'package:tayseer/my_import.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final bool isDetailsView;
  // لاستقبال الكنترولر من الصفحة السابقة (في حالة الديتيلز)
  final VideoPlayerController? sharedController;

  const PostCard({
    super.key,
    required this.post,
    this.isDetailsView = false,
    this.sharedController,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

// ✅ إضافة AutomaticKeepAliveClientMixin للحفاظ على الفيديو شغال في الخلفية
class _PostCardState extends State<PostCard>
    with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _activeController;

  @override
  bool get wantKeepAlive => true; // ✅ يمنع تدمير الـ Widget

  @override
  void initState() {
    super.initState();
    // لو جالنا كنترولر من بره (إحنا في صفحة الديتيلز)، نمسكه
    if (widget.sharedController != null) {
      _activeController = widget.sharedController;
    }
  }

  void _navigateToDetails(BuildContext context) {
    if (widget.isDetailsView) {
      context.read<PostDetailsCubit>().requestInputFocus();
      return;
    }

    // Read HomeCubit before navigation to avoid context issues
    final homeCubit = context.read<HomeCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailsView(
          homeCubit: homeCubit,
          post: widget.post,
          // ✅ نبعت الكنترولر الحالي عشان الفيديو يكمل
          cachedController: _activeController,
        ),
      ),
    ).then((_) {
      // ✅ عند العودة للهوم، نتأكد إن الفيديو جاهز وممكن يكمل شغل
      if (mounted &&
          _activeController != null &&
          _activeController!.value.isInitialized) {
        // خيار: تشغيل الفيديو تلقائياً عند العودة إذا كان واقفاً
        // _activeController!.play();
        setState(() {}); // تحديث الواجهة
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            onMoreTap: () {},
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
              onHashtagTap: (hashtag) {
                log("User tapped on: $hashtag");
                context.pushNamed(AppRouter.kAdvisorSearchView);
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
              context.read<HomeCubit>().reactToPost(
                postId: widget.post.postId,
                reactionType: react,
              );
            },
            onShareTap: () {
              context.read<HomeCubit>().toggleSharePost(
                postId: widget.post.postId,
              );
            },
          ),
        ],
      ),
    );

    // ✅ التعديل هنا: لغينا الـ Hero ورجعنا الـ cardContent مباشرة
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
                postId: widget.post.postId, // ✅ ضروري جداً
                post: widget.post, // ✅ عشان الداتا اللي تحت في الفيو
              )
            : const SizedBox.shrink();
      case PostContentType.video:
        return RealVideoPlayer(
          videoUrl: widget.post.videoUrl ?? '',
          isReel: false,
          // ✅ نمرر الكنترولر الحالي ليتم استخدامه بدلاً من إنشاء جديد
          videoController: _activeController,
          onControllerCreated: (controller) {
            _activeController = controller;
          },
        );

      case PostContentType.reel:
        return RealVideoPlayer(
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
                controller.play();
              }
            });
          },
        );
    }
  }
}
