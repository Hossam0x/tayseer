import 'package:tayseer/core/functions/count_formate.dart';
import 'package:tayseer/core/widgets/post_card/circular_icon_button.dart';
import 'package:tayseer/core/widgets/post_card/reaction_like_button.dart';
import 'package:tayseer/core/widgets/post_card/share_button.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

/// PostActionsRow - Handles reaction, comment, and share interactions
///
/// Optimized Features:
/// - Uses StatefulWidget for local GlobalKey management
/// - Extracted sub-widgets for better readability
/// - Uses final fields where possible
class PostActionsRow extends StatefulWidget {
  final int likesCount;
  final List<ReactionType> topReactions;
  final ReactionType? myReaction;
  final bool isRepostedByMe;
  final void Function(ReactionType?) onReactionChanged;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;
  final GlobalKey? externalDestinationKey;

  const PostActionsRow({
    super.key,
    required this.likesCount,
    required this.topReactions,
    this.myReaction,
    required this.isRepostedByMe,
    required this.onReactionChanged,
    this.onCommentTap,
    this.onShareTap,
    this.externalDestinationKey,
  });

  @override
  State<PostActionsRow> createState() => _PostActionsRowState();
}

class _PostActionsRowState extends State<PostActionsRow> {
  final GlobalKey _internalStackKey = GlobalKey();

  GlobalKey get _destinationKey =>
      widget.externalDestinationKey ?? _internalStackKey;

  bool get _hasReactions =>
      widget.likesCount > 0 || widget.topReactions.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Action Buttons
        _ActionButtons(
          myReaction: widget.myReaction,
          destinationKey: _destinationKey,
          onReactionChanged: widget.onReactionChanged,
          onCommentTap: widget.onCommentTap,
          isRepostedByMe: widget.isRepostedByMe,
          onShareTap: widget.onShareTap,
        ),

        const Spacer(),

        // Reactions Display
        if (_hasReactions)
          _ReactionsDisplay(
            likesCount: widget.likesCount,
            topReactions: widget.topReactions,
            destinationKey: _destinationKey,
          )
        else
          Container(key: _destinationKey),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Action Buttons (Like, Comment, Share)
// ══════════════════════════════════════════════════════════════════════════════

class _ActionButtons extends StatelessWidget {
  final ReactionType? myReaction;
  final GlobalKey destinationKey;
  final void Function(ReactionType?) onReactionChanged;
  final VoidCallback? onCommentTap;
  final bool isRepostedByMe;
  final VoidCallback? onShareTap;

  const _ActionButtons({
    required this.myReaction,
    required this.destinationKey,
    required this.onReactionChanged,
    this.onCommentTap,
    required this.isRepostedByMe,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ReactionLikeButton(
          initialReaction: myReaction,
          destinationKey: destinationKey,
          onReactionChanged: onReactionChanged,
        ),
        Gap(15.w),
        CircularIconButton(icon: AssetsData.commentIcon, onTap: onCommentTap),
        Gap(15.w),
        ShareButton(
          isShared: isRepostedByMe,
          onShareTapped: () => onShareTap?.call(),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reactions Display (Count + Stack)
// ══════════════════════════════════════════════════════════════════════════════

class _ReactionsDisplay extends StatelessWidget {
  final int likesCount;
  final List<ReactionType> topReactions;
  final GlobalKey destinationKey;

  const _ReactionsDisplay({
    required this.likesCount,
    required this.topReactions,
    required this.destinationKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatCount(likesCount),
          style: Styles.textStyle12SemiBold.copyWith(
            color: AppColors.kprimaryColor,
          ),
        ),
        Gap(6.w),
        Container(
          key: destinationKey,
          child: topReactions.isNotEmpty
              ? _ReactionStack(reactions: topReactions)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reaction Stack (Overlapping reaction icons)
// ══════════════════════════════════════════════════════════════════════════════

class _ReactionStack extends StatelessWidget {
  final List<ReactionType> reactions;

  const _ReactionStack({required this.reactions});

  static const double _iconSize = 22;
  static const double _overlap = 15;

  double get _width => _iconSize + ((reactions.length - 1) * _overlap);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _iconSize.w,
      width: _width.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (int i = 0; i < reactions.length; i++)
            _buildReactionIcon(i, reactions[i]),
        ],
      ),
    );
  }

  Widget _buildReactionIcon(int index, ReactionType type) {
    return Positioned(
      left: index * _overlap.w,
      child: Container(
        width: _iconSize.w,
        height: _iconSize.w,
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
            getReactionAsset(type),
            fit: BoxFit.cover,
            height: (_iconSize - 2).w,
            width: (_iconSize - 2).w,
          ),
        ),
      ),
    );
  }
}
