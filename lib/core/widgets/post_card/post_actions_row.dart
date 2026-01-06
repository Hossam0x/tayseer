import 'package:tayseer/core/functions/count_formate.dart';
import 'package:tayseer/core/widgets/post_card/circular_icon_button.dart';
import 'package:tayseer/core/widgets/post_card/reaction_like_button.dart';
import 'package:tayseer/core/widgets/post_card/share_button.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

class PostActionsRow extends StatelessWidget {
  final int likesCount;
  final List<ReactionType> topReactions;
  final ReactionType? myReaction;
  final bool isRepostedByMe;
  final Function(ReactionType?) onReactionChanged;
  final VoidCallback? onCommentTap;

  // ✅ 1. استقبال مفتاح خارجي (اختياري)
  // ده اللي هيتبعت من ImageViewerView
  final GlobalKey? externalDestinationKey;

  // ✅ 2. مفتاح داخلي احتياطي
  // ده عشان لو استخدمنا الويدجت في مكان تاني من غير ما نبعت مفتاح، تفضل شغالة
  final GlobalKey _internalStackKey = GlobalKey();

  // ✅ 3. Getter ذكي يختار المفتاح المناسب
  GlobalKey get _destinationKey => externalDestinationKey ?? _internalStackKey;

  PostActionsRow({
    super.key,
    required this.likesCount,
    required this.topReactions,
    this.myReaction,
    required this.isRepostedByMe,
    this.onCommentTap,
    required this.onReactionChanged,
    this.externalDestinationKey, // ضفناه هنا
  });

  bool get hasReactions => likesCount > 0 || topReactions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            // ✅ 4. تمرير المفتاح الصح لزر اللايك
            ReactionLikeButton(
              initialReaction: myReaction,
              destinationKey: _destinationKey,
              onReactionChanged: onReactionChanged,
            ),
            Gap(15.w),

            CircularIconButton(
              icon: AssetsData.commentIcon,
              onTap: onCommentTap,
            ),
            Gap(15.w),

            ShareButton(
              initialState: isRepostedByMe,
              onShareTapped: (isShared) {
                print("Share state changed to: $isShared");
              },
            ),
          ],
        ),
        const Spacer(),

        if (hasReactions) ...[
          Text(
            formatCount(likesCount),
            style: Styles.textStyle12SemiBold.copyWith(
              color: AppColors.kprimaryColor,
            ),
          ),
          Gap(6.w),

          // ✅ 5. ربط المفتاح بالكونتينر (الوجهة النهائية)
          Container(
            key: _destinationKey,
            child: topReactions.isNotEmpty
                ? _ReactionStack(reactions: topReactions)
                : const SizedBox.shrink(),
          ),
        ] else
          // ✅ ضروري: عشان المفتاح يفضل موجود في الشجرة حتى لو مفيش رياكشنز
          Container(key: _destinationKey),
      ],
    );
  }
}

class _ReactionStack extends StatelessWidget {
  final List<ReactionType> reactions;
  const _ReactionStack({required this.reactions});

  @override
  Widget build(BuildContext context) {
    final double stackWidth = 22.w + ((reactions.length - 1) * 15.w);
    return SizedBox(
      height: 22.w,
      width: stackWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(reactions.length, (index) {
          return Positioned(
            left: index * 15.w,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: AppImage(
                  getReactionAsset(reactions[index]),
                  fit: BoxFit.cover,
                  height: 20.w,
                  width: 20.w,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
