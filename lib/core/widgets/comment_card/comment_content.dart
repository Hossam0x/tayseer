import 'package:tayseer/core/models/comment_model.dart';
import 'package:tayseer/core/widgets/comment_card/comment_actions_menu.dart';
import 'package:tayseer/core/widgets/comment_card/comment_avatar.dart';
import 'package:tayseer/core/widgets/comment_card/comment_callbacks.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
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
  final CommentCallbacks callbacks;

  const CommentContent({
    super.key,
    required this.comment,
    this.isReply = false,
    this.isReplying = false,
    this.callbacks = CommentCallbacks.empty,
  });

  void _navigateToUserAdvisorProfile(BuildContext context) {
    // التحقق من أن هذا ليس بروفايل المستخدم الحالي
    // يمكنك استخدام getIt أو أي طريقة أخرى للتحقق من الـ current user id

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserAdvisorProfileView(advisorId: comment.commenter.id),
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context) {
    // ⭐ التحقق من وجود الـ ID
    if (comment.commenter.id.isEmpty) {
      // ⭐ يمكنك إظهار رسالة خطأ أو عدم القيام بأي شيء
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserPublicProfileView(
          userId: comment.commenter.id, // ⭐ استخدام ! بعد التأكد
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              if (comment.commenter.isAnnonymous) {
                // لا تفعل شيئًا أو أظهر رسالة
                return;
              }
              comment.commenter.userType == 'Advisor'
                  ? _navigateToUserAdvisorProfile(context)
                  : _navigateToUserProfile(context);
            },
            child: CommentAvatar(
              isAnnonymous: comment.commenter.isAnnonymous,
              avatarUrl: comment.commenter.avatar,
              isReply: isReply,
            ),
          ),
          Gap(10.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CommentHeader(
                  comment: comment,
                  isReply: isReply,
                  callbacks: callbacks,
                ),

                Gap(6.h),
                _CommentText(text: comment.comment),
                Gap(8.h),
                _CommentActions(
                  comment: comment,

                  isReply: isReply,
                  isReplying: isReplying,
                  callbacks: callbacks,
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

// ══════════════════════════════════════════════════════════════════════════════
// Header (Name + Verified Badge)
// ══════════════════════════════════════════════════════════════════════════════
class _CommentHeader extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;
  final CommentCallbacks callbacks;

  const _CommentHeader({
    required this.comment,
    required this.isReply,
    required this.callbacks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      comment.commenter.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: const Color(0xFF19295C),
                      ),
                    ),
                  ),
                  Gap(4.w),
                  if (comment.commenter.isVerified &&
                      !comment.commenter.isAnnonymous)
                    Icon(Icons.verified, color: Colors.blue, size: 14.sp),
                ],
              ),

              Row(
                children: [
                  Flexible(
                    child: Text(
                      comment.commenter.isAnnonymous
                          ? ""
                          : comment.commenter.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.kGreyB3,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                  Gap(4.w),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.public, size: 12.sp, color: AppColors.kGreyB3),
                      Gap(4.w),
                      Text(
                        comment.timeAgo,
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.kGreyB3,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Gap(8.w),
        CommentActionsMenu(
          isOwner: comment.isOwner,
          isReply: isReply,
          commentId: comment.id,
          callbacks: callbacks,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Meta (Username + Time)
// ══════════════════════════════════════════════════════════════════════════════

// ══════════════════════════════════════════════════════════════════════════════
// Comment Text
// ══════════════════════════════════════════════════════════════════════════════

class _CommentText extends StatelessWidget {
  final String text;

  const _CommentText({required this.text});

  bool _isEmojiOnly(String text) {
    final emojiRegex = RegExp(
      r'^(?:[\u{1F300}-\u{1FAFF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}|\u{FE0F}|\u{1F1E6}-\u{1F1FF}]+)$',
      unicode: true,
    );
    return emojiRegex.hasMatch(text.replaceAll(' ', ''));
  }

  int _emojiCount(String text) {
    final emojiRegex = RegExp(
      r'[\u{1F300}-\u{1FAFF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}|\u{FE0F}|\u{1F1E6}-\u{1F1FF}]',
      unicode: true,
    );
    return emojiRegex.allMatches(text).length;
  }

  double _fontSize() {
    if (!_isEmojiOnly(text)) {
      return 14; // الحجم العادي
    }

    final count = _emojiCount(text);

    if (count == 1) {
      return 40; // إيموجي واحد
    } else if (count <= 7) {
      return 28; // من 2 لـ 7
    } else {
      return 14; // كتير
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
      style: Styles.textStyle14.copyWith(
        fontSize: _fontSize(),
        color: Colors.black,
        height: 1.5,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Actions (Like, Reply, Edit)
// ══════════════════════════════════════════════════════════════════════════════
class _CommentActions extends StatelessWidget {
  final CommentModel comment;
  final bool isReply;
  final bool isReplying;
  final CommentCallbacks callbacks;

  const _CommentActions({
    required this.comment,
    required this.isReply,
    required this.isReplying,
    required this.callbacks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ✅ Like Button
        _LikeButton(
          isLiked: comment.isLiked,
          // حل مشكلة String to int: نقوم بتحويل النص إلى رقم
          likesCount: int.tryParse(comment.likes.toString()) ?? 0,
          // حل مشكلة الاستدعاء: نستخدم anonymous function
          onTap: () => callbacks.onLike?.call(comment, isReply),
        ),

        // ✅ Reply Button (فقط للتعليقات الأساسية)
        if (!isReply) ...[
          const _Separator(),
          _ReplyButton(
            isReplying: isReplying,
            onTap: () => callbacks.onReplyToggle?.call(comment.id),
          ),
        ],

        // ✅ Edit Button (فقط لصاحب التعليق)
        if (comment.isOwner) ...[
          const _Separator(),
          _EditButton(onTap: () => callbacks.onEditToggle?.call(comment.id)),
        ],
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
