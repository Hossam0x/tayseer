import 'dart:ui';
import 'package:tayseer/core/utils/animation/fly_animation.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

/// ReactionLikeButton - Handles like/reaction functionality with animations
///
/// Features:
/// - Long press for reaction picker
/// - Tap for quick like/unlike
/// - Fly animation to reaction stack
class ReactionLikeButton extends StatefulWidget {
  final ReactionType? initialReaction;
  final void Function(ReactionType?) onReactionChanged;
  final GlobalKey? destinationKey;
  final double? height;
  final double? width;

  const ReactionLikeButton({
    super.key,
    this.initialReaction,
    required this.onReactionChanged,
    this.destinationKey,
    this.height,
    this.width,
  });

  @override
  State<ReactionLikeButton> createState() => _ReactionLikeButtonState();
}

class _ReactionLikeButtonState extends State<ReactionLikeButton> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _buttonKey = GlobalKey();

  ReactionType? _selectedReaction;
  OverlayEntry? _overlayEntry;

  double get _size => widget.width ?? 38;
  double get _padding => _size > 38 ? 12 : 6;

  @override
  void initState() {
    super.initState();
    _selectedReaction = widget.initialReaction;
  }

  @override
  void didUpdateWidget(covariant ReactionLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialReaction != widget.initialReaction) {
      setState(() => _selectedReaction = widget.initialReaction);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Overlay Management
  // ══════════════════════════════════════════════════════════════════════════

  void _showReactionOverlay() {
    _hideOverlay();

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Dismiss on tap outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideOverlay,
              behavior: HitTestBehavior.translucent,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          // Reaction bubble
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: true,
            targetAnchor: isRtl ? Alignment.topRight : Alignment.topLeft,
            followerAnchor: isRtl
                ? Alignment.bottomRight
                : Alignment.bottomLeft,
            offset: Offset(0, -12.h),
            child: Material(
              color: Colors.transparent,
              child: _ReactionBubble(
                onSelected: (reaction, sourceKey) {
                  _hideOverlay();
                  _triggerFlyAnimation(reaction, sourceKey);
                },
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Reaction Handling
  // ══════════════════════════════════════════════════════════════════════════

  void _triggerFlyAnimation(ReactionType reaction, GlobalKey? sourceKey) {
    setState(() => _selectedReaction = reaction);

    if (widget.destinationKey != null && sourceKey != null) {
      FlyAnimation.flyWidget(
        context: context,
        startKey: sourceKey,
        endKey: widget.destinationKey!,
        child: Container(
          width: 30.w,
          height: 30.w,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: AppImage(getReactionAsset(reaction), fit: BoxFit.contain),
        ),
        onComplete: () => widget.onReactionChanged(reaction),
      );
    } else {
      widget.onReactionChanged(reaction);
    }
  }

  void _onTap() {
    if (_selectedReaction != null) {
      // Remove reaction
      setState(() => _selectedReaction = null);
      widget.onReactionChanged(null);
    } else {
      // Quick like with love reaction
      _triggerFlyAnimation(ReactionType.love, _buttonKey);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // UI Helpers
  // ══════════════════════════════════════════════════════════════════════════

  Color get _backgroundColor {
    return switch (_selectedReaction) {
      ReactionType.love => const Color(0xffD8779B),
      ReactionType.care => const Color(0xffDBC195),
      ReactionType.dislike => const Color(0xffD98D80),
      null => const Color(0xFFFCE9ED),
    };
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _onTap,
        onLongPress: _showReactionOverlay,
        child: Container(
          key: _buttonKey,
          width: context.responsiveWidth(_size),
          height: context.responsiveWidth(_size),
          padding: EdgeInsets.all(_padding.r),
          decoration: BoxDecoration(
            color: _backgroundColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedReaction == null) {
      return AppImage(
        AssetsData.loveDefault,
        fit: BoxFit.contain,
        height: double.infinity,
        width: double.infinity,
      );
    }

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppImage(
        getReactionAsset(_selectedReaction!),
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.contain,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Reaction Bubble (Overlay picker)
// ══════════════════════════════════════════════════════════════════════════════

class _ReactionBubble extends StatefulWidget {
  final void Function(ReactionType, GlobalKey?) onSelected;

  const _ReactionBubble({required this.onSelected});

  @override
  State<_ReactionBubble> createState() => _ReactionBubbleState();
}

class _ReactionBubbleState extends State<_ReactionBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  final Map<ReactionType, GlobalKey> _reactionKeys = {
    ReactionType.love: GlobalKey(),
    ReactionType.care: GlobalKey(),
    ReactionType.dislike: GlobalKey(),
  };

  static const _reactions = [
    (type: ReactionType.love, color: Color(0xFFE040FB)),
    (type: ReactionType.care, color: Color(0xFFFFD740)),
    (type: ReactionType.dislike, color: Color(0xFFFF5252)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF5D3DA).withOpacity(0.3),
              borderRadius: BorderRadius.circular(31.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _reactions.map(_buildReactionItem).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReactionItem(({ReactionType type, Color color}) reaction) {
    return GestureDetector(
      onTap: () =>
          widget.onSelected(reaction.type, _reactionKeys[reaction.type]),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Container(
          width: context.responsiveWidth(45),
          height: context.responsiveWidth(45),
          decoration: BoxDecoration(
            color: reaction.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            key: _reactionKeys[reaction.type],
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff787878).withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: AppImage(
              getReactionAsset(reaction.type),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
