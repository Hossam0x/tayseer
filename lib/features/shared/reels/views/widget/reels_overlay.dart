import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/functions/count_formate.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/utils/video_download_service.dart';
import 'package:tayseer/core/widgets/follow_button.dart';
import 'package:tayseer/core/widgets/post_card/circular_icon_button.dart';
import 'package:tayseer/core/widgets/post_card/post_options_bottom_sheet.dart';
import 'package:tayseer/core/widgets/post_card/reaction_like_button.dart';
import 'package:tayseer/core/widgets/post_card/share_button.dart';
import 'package:tayseer/core/widgets/social_text_parser.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/shared/reels/views/widget/reels_comments_bottom_sheet.dart';
import 'package:tayseer/my_import.dart';

class ReelsOverlay extends StatelessWidget {
  final PostModel post;
  final dynamic Function(ReactionType?) onReactionChanged;
  final VoidCallback onShareTapped;
  final VoidCallback? onSaveTapped;
  final VideoPlayerController? cachedController;
  final GlobalKey? likeButtonKey;
  final VoidCallback? onClose;

  const ReelsOverlay({
    super.key,
    required this.post,
    required this.onReactionChanged,
    required this.onShareTapped,
    required this.onSaveTapped,
    this.cachedController,
    this.likeButtonKey,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      bottom: false,
      child: Column(
        children: [
          _buildHeader(context),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: 24.h + 10.h + bottomPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSideActions(context),
                Gap(10.w),
                Expanded(child: _buildUserInfo(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
          border: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (onClose != null) {
                    onClose!();
                  } else {
                    context.pop();
                  }
                },
                child: Icon(Icons.close, color: Colors.white, size: 28.sp),
              ),
              if (canAct && !post.isMine)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.pushNamed(
                      AppRouter.kReportsView,
                      arguments: {'type': ReportType.post, 'id': post.postId},
                    );
                  },
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 26.sp,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!post.isMine)
                        FollowButton(
                          key: ValueKey(post.isFollowing),
                          isFollowing: post.isFollowing,
                          onTap: () {
                            if (context
                                    .read<ReelsCubit>()
                                    .state
                                    .followActionState ==
                                CubitStates.loading) {
                              return;
                            }
                            context.read<ReelsCubit>().toggleFollowAdvisor(
                              advisorId: post.advisorId,
                            );
                          },
                        ),
                      Gap(8.w),
                      if (post.isVerified)
                        Icon(Icons.verified, color: Colors.blue, size: 16.sp),
                      Gap(4.w),
                      Flexible(
                        child: GestureDetector(
                          onTap: () {
                            context.pushNamed(
                              AppRouter.kUserProfileView,
                              arguments: {
                                'advisorId': post.advisorId,
                                'advisorName': post.name,
                              },
                            );
                          },
                          child: Text(
                            post.name,
                            style: Styles.textStyle16.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        post.timeAgo,
                        style: Styles.textStyle12.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Gap(context.responsiveWidth(5)),
                      Icon(Icons.public, color: Colors.white70, size: 12.sp),
                      Gap(context.responsiveWidth(5)),
                      Flexible(
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            post.userName,
                            style: Styles.textStyle12.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Gap(10.w),
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  AppRouter.kUserProfileView,
                  arguments: {
                    'advisorId': post.advisorId,
                    'advisorName': post.name,
                  },
                );
              },
              child: Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: ClipOval(
                  child: AppImage(
                    post.avatar,
                    width: 45.w,
                    height: 45.w,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        Gap(8.h),
        _ReelsExpandableContent(content: post.content),
      ],
    );
  }

  Widget _buildSideActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: context.responsiveHeight(22),
      children: [
        _buildCircleActionBtn(
          child: SizedBox(
            key: likeButtonKey,
            child: ReactionLikeButton(
              height: 50,
              width: 50,
              onReactionChanged: onReactionChanged,
              initialReaction: post.myReaction,
            ),
          ),
          count: post.likesCount,
        ),
        _buildCircleActionBtn(
          child: CircularIconButton(
            height: 50,
            width: 50,
            icon: AssetsData.commentIcon,
            backgroundColor: const Color(0xFFFCE9ED),
            onTap: () => _openCommentsSheet(context),
          ),
          count: post.commentsCount,
        ),
        _buildCircleActionBtn(
          child: ShareButton(
            height: 50,
            width: 50,
            onShareTapped: onShareTapped,
            isShared: post.isRepostedByMe,
          ),
          count: post.sharesCount,
        ),
        CircularIconButton(
          height: 50,
          width: 50,
          icon: AssetsData.moreIcon,
          iconColor: HexColor("#F2A6B5"),
          backgroundColor: const Color(0xFFFCE9ED),
          onTap: () {
            PostOptionsBottomSheet.show(
              context,
              post: post,
              onShare: onShareTapped,
              isShared: post.isRepostedByMe,
              isFromReels: true,
              onSave: onSaveTapped,
              onDownload: () {
                VideoDownloadService().downloadVideo(
                  context: context,
                  videoUrl: post.videoUrl ?? '',
                );
              },
              onEdit: (updatedPost) {
                context.read<ReelsCubit>().updateEditedReel(updatedPost);
                getIt<HomeCubit>().updateEditedPost(updatedPost);
              },
            );
          },
        ),
      ],
    );
  }

  void _openCommentsSheet(BuildContext context) {
    final reelsCubit = context.read<ReelsCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReelsCommentsBottomSheet(
        post: post,
        onCommentCountChanged: (newCount, isCommented, isAnonymous) {
          reelsCubit.updateReelCommentCount(
            postId: post.postId,
            newCount: newCount,
            isCommented: isCommented,
            isAnonymous: isAnonymous,
          );
        },
      ),
    );
  }

  Widget _buildCircleActionBtn({required int count, required Widget child}) {
    return Column(
      children: [
        child,
        Gap(4.h),
        Text(
          formatCount(count),
          style: Styles.textStyle12.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: const [
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ Widget منفصل — يستخدم SocialTextParser مباشرة
//    1. الضغط على النص نفسه يعمل expand/collapse
//    2. "عرض المزيد" inline في نهاية السطر — زي فيسبوك
//    3. scroll لو النص طويل جداً
// ═══════════════════════════════════════════════════════════════
class _ReelsExpandableContent extends StatefulWidget {
  final String content;

  const _ReelsExpandableContent({required this.content});

  @override
  State<_ReelsExpandableContent> createState() =>
      _ReelsExpandableContentState();
}

class _ReelsExpandableContentState extends State<_ReelsExpandableContent> {
  bool _isExpanded = false;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    if (widget.content.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final textStyle = Styles.textStyle14.copyWith(
      color: Colors.white,
      height: 1.5,
    );
    final hashtagStyle = Styles.textStyle14Bold.copyWith(color: Colors.blue);
    final seeMoreStyle = Styles.textStyle14.copyWith(
      color: Colors.white70,
      fontWeight: FontWeight.w600,
    );

    final maxExpandedHeight = MediaQuery.of(context).size.height * 0.35;

    return LayoutBuilder(
      builder: (context, constraints) {
        // نحسب هل النص يتجاوز سطر واحد ولا لأ
        final textPainter = TextPainter(
          text: TextSpan(text: widget.content, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.rtl,
        )..layout(maxWidth: constraints.maxWidth);

        final exceedsOneLine = textPainter.didExceedMaxLines;

        // ════════════════════════════
        // الحالة 1: collapsed (سطر واحد + "عرض المزيد" inline)
        // ════════════════════════════
        if (!_isExpanded) {
          // لو النص قصير ومش محتاج "عرض المزيد"
          if (!exceedsOneLine) {
            return GestureDetector(
              onTap: _toggle,
              child: SocialTextParser(
                text: widget.content,
                style: textStyle,
                hashtagStyle: hashtagStyle,
                parseMentions: false,
              ),
            );
          }

          // لو النص طويل — نعرض سطر واحد مقطوع + "عرض المزيد" inline
          // نحسب كام حرف يقدر يتسع في السطر مع مراعاة مساحة "عرض المزيد"
          final seeMoreText = " ...${context.tr("see_more")}";
          final seeMorePainter = TextPainter(
            text: TextSpan(text: seeMoreText, style: seeMoreStyle),
            textDirection: TextDirection.rtl,
          )..layout();

          final availableWidth =
              constraints.maxWidth - seeMorePainter.width - 4;

          // نقطع النص بحيث يتسع مع "عرض المزيد" في نفس السطر
          String truncatedText = widget.content;
          final truncPainter = TextPainter(
            text: TextSpan(text: truncatedText, style: textStyle),
            maxLines: 1,
            textDirection: TextDirection.rtl,
          )..layout(maxWidth: availableWidth);

          if (truncPainter.didExceedMaxLines) {
            // Binary search للحصول على أطول نص يتسع
            int low = 0;
            int high = widget.content.length;
            int bestFit = 0;

            while (low <= high) {
              final mid = (low + high) ~/ 2;
              final testPainter = TextPainter(
                text: TextSpan(
                  text: widget.content.substring(0, mid),
                  style: textStyle,
                ),
                maxLines: 1,
                textDirection: TextDirection.rtl,
              )..layout(maxWidth: availableWidth);

              if (testPainter.didExceedMaxLines) {
                high = mid - 1;
              } else {
                bestFit = mid;
                low = mid + 1;
              }
            }

            truncatedText = widget.content.substring(0, bestFit);
          }

          return GestureDetector(
            onTap: _toggle,
            child: RichText(
              maxLines: 1,
              overflow: TextOverflow.clip,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                children: [
                  TextSpan(text: truncatedText, style: textStyle),
                  TextSpan(text: " ...", style: textStyle),
                  TextSpan(text: context.tr("see_more"), style: seeMoreStyle),
                ],
              ),
            ),
          );
        }

        // ════════════════════════════
        // الحالة 2: expanded (نص كامل + scroll لو طويل)
        // ════════════════════════════
        return GestureDetector(
          onTap: _toggle,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: maxExpandedHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // النص — scrollable لو أطول من maxHeight
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SocialTextParser(
                      text: widget.content,
                      style: textStyle,
                      hashtagStyle: hashtagStyle,
                      parseMentions: false,
                    ),
                  ),
                ),
                Gap(6.h),
                // "عرض أقل"
                Text(
                  context.tr("see_less"),
                  style: seeMoreStyle,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
