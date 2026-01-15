import 'package:tayseer/features/shared/home/model/comment_model.dart';
import 'package:tayseer/my_import.dart';

/// CommentContent - Displays comment information
///
/// Static widget that shows:
/// - Avatar, Name, Username
/// - Comment text
/// - Actions (Like, Reply, Edit)
class CommentContent extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;
  final bool isReplying;
  final VoidCallback? onLikeTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onEditTap;

  const CommentContent({
    super.key,
    required this.comment,
    this.isReply = false,
    this.isReplying = false,
    this.onLikeTap,
    this.onReplyTap,
    this.onEditTap,
  });

  double get _avatarSize => isReply ? 32 : 40;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _CommentAvatar(
            avatarUrl: comment.commenter.avatar,
            size: _avatarSize,
          ),
          Gap(10.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommentHeader(
                  name: comment.commenter.name,
                  isVerified: comment.commenter.isVerified,
                ),
                _CommentMeta(
                  userName: comment.commenter.userName,
                  timeAgo: comment.timeAgo,
                ),
                Gap(6.h),
                _CommentText(text: comment.comment),
                Gap(8.h),
                _CommentActions(
                  isLiked: comment.isLiked,
                  likesCount: comment.likes,
                  isReply: isReply,
                  isReplying: isReplying,
                  isOwner: comment.isOwner,
                  onLikeTap: onLikeTap,
                  onReplyTap: onReplyTap,
                  onEditTap: onEditTap,
                ),
                Gap(5.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Avatar
// ══════════════════════════════════════════════════════════════════════════════

class _CommentAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;

  const _CommentAvatar({this.avatarUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.r,
      width: size.r,
      child: ClipOval(child: AppImage(avatarUrl ?? '', fit: BoxFit.cover)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Header (Name + Verified Badge)
// ══════════════════════════════════════════════════════════════════════════════

class _CommentHeader extends StatelessWidget {
  final String name;
  final bool isVerified;

  const _CommentHeader({required this.name, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          name,
          style: Styles.textStyle16SemiBold.copyWith(
            color: const Color(0xFF19295C),
          ),
        ),
        Gap(4.w),
        if (isVerified) Icon(Icons.verified, color: Colors.blue, size: 14.sp),
        const Spacer(),
        Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20.sp),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Meta (Username + Time)
// ══════════════════════════════════════════════════════════════════════════════

class _CommentMeta extends StatelessWidget {
  final String userName;
  final String timeAgo;

  const _CommentMeta({required this.userName, required this.timeAgo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          userName,
          style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
          textDirection: TextDirection.ltr,
        ),
        Gap(4.w),
        Icon(Icons.public, size: 12.sp, color: AppColors.kGreyB3),
        Gap(4.w),
        Text(
          timeAgo,
          style: Styles.textStyle12.copyWith(color: AppColors.kGreyB3),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Comment Text
// ══════════════════════════════════════════════════════════════════════════════

class _CommentText extends StatelessWidget {
  final String text;

  const _CommentText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Styles.textStyle14.copyWith(color: Colors.black, height: 1.5),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Actions (Like, Reply, Edit)
// ══════════════════════════════════════════════════════════════════════════════

class _CommentActions extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final bool isReply;
  final bool isReplying;
  final bool isOwner;
  final VoidCallback? onLikeTap;
  final VoidCallback? onReplyTap;
  final VoidCallback? onEditTap;

  const _CommentActions({
    required this.isLiked,
    required this.likesCount,
    required this.isReply,
    required this.isReplying,
    required this.isOwner,
    this.onLikeTap,
    this.onReplyTap,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Like Button
        _LikeButton(isLiked: isLiked, likesCount: likesCount, onTap: onLikeTap),

        // Reply Button (only for main comments)
        if (!isReply) ...[
          const _Separator(),
          _ReplyButton(isReplying: isReplying, onTap: onReplyTap),
        ],

        // Edit Button (only for owner)
        if (isOwner) ...[const _Separator(), _EditButton(onTap: onEditTap)],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Action Sub-Widgets
// ══════════════════════════════════════════════════════════════════════════════

class _LikeButton extends StatelessWidget {
  final bool isLiked;
  final int likesCount;
  final VoidCallback? onTap;

  const _LikeButton({
    required this.isLiked,
    required this.likesCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          AppImage(
            AssetsData.loveDefault,
            height: 18.w,
            width: 18.w,
            fit: BoxFit.contain,
            color: isLiked ? Colors.red : const Color(0xFFB3B3B3),
          ),
          Gap(4.w),
          Text(
            '$likesCount',
            style: Styles.textStyle12.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ReplyButton extends StatelessWidget {
  final bool isReplying;
  final VoidCallback? onTap;

  const _ReplyButton({required this.isReplying, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        context.tr(AppStrings.reply),
        style: Styles.textStyle14.copyWith(
          color: isReplying ? const Color(0xFFD65A73) : const Color(0xFF4267B2),
          fontWeight: isReplying ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _EditButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        context.tr(AppStrings.edit),
        style: Styles.textStyle14.copyWith(color: HexColor("#06A62D")),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Gap(10.w),
        const Text('•', style: TextStyle(color: Colors.black)),
        Gap(10.w),
      ],
    );
  }
}
