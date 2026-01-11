import 'dart:ui';
import 'package:tayseer/core/utils/animation/fly_animation.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

class ReactionLikeButton extends StatefulWidget {
  final ReactionType? initialReaction;
  final Function(ReactionType?) onReactionChanged;
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

  // ✅ 1. مفتاح للزرار نفسه (المصدر عند الضغط المباشر)
  final GlobalKey _buttonKey = GlobalKey();

  ReactionType? _selectedReaction;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _selectedReaction = widget.initialReaction;
  }

  @override
  void didUpdateWidget(covariant ReactionLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialReaction != widget.initialReaction) {
      setState(() {
        _selectedReaction = widget.initialReaction;
      });
    }
  }

  // ... (دالة _showReactionOverlay زي ما هي) ...
  void _showReactionOverlay() {
    _hideOverlay();

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
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
              child: ReactionBubble(
                onSelected: (reaction, sourceKey) {
                  _hideOverlay();
                  // أنيميشن القائمة (Overlay)
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

  // ✅ دالة موحدة لتشغيل الأنيميشن وتحديث الداتا
  void _triggerFlyAnimation(ReactionType reaction, GlobalKey? sourceKey) {
    // نحدث الزرار فوراً عشان اليوزر يحس بالاستجابة
    setState(() {
      _selectedReaction = reaction;
    });

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
        onComplete: () {
          // نحدث الـ Cubit والـ Stack لما الأنيميشن يوصل
          widget.onReactionChanged(reaction);
        },
      );
    } else {
      // لو مفيش أنيميشن، نحدث الـ Cubit علطول
      widget.onReactionChanged(reaction);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 التعديل هنا في الـ ON TAP
  // ═══════════════════════════════════════════════════════════
  void _onTap() {
    if (_selectedReaction != null) {
      // 1. حالة الإزالة (Remove Like)
      setState(() {
        _selectedReaction = null;
      });
      // تحديث مباشر بدون أنيميشن للإزالة
      widget.onReactionChanged(null);
    } else {
      // 2. حالة الإضافة (Add Love)
      // بنستخدم _buttonKey كمصدر للأنيميشن
      _triggerFlyAnimation(ReactionType.love, _buttonKey);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Color getBackgroundColor() {
    switch (_selectedReaction) {
      case ReactionType.love:
        return const Color(0xffD8779B);
      case ReactionType.care:
        return const Color(0xffDBC195);
      case ReactionType.dislike:
        return const Color(0xffD98D80);
      case null:
        return const Color(0xFFFCE9ED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _onTap,
        onLongPress: _showReactionOverlay,
        child: Container(
          // ✅ 2. ربطنا المفتاح بالزرار هنا
          key: _buttonKey,
          width: context.responsiveWidth(widget.width ?? 38),
          height: context.responsiveWidth(widget.height ?? 38),
          padding: EdgeInsets.all((widget.width ?? 38) > 38 ? 12.r : 6.r),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(child: _buildButtonContent()),
        ),
      ),
    );
  }

  Widget _buildButtonContent() {
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
      child: Center(
        child: AppImage(
          getReactionAsset(_selectedReaction!),
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
// ==========================================================
// ✅ ReactionBubble المعدلة (بتنشئ مفاتيح للمصادر)

class ReactionBubble extends StatefulWidget {
  // ✅ تعديل الـ Callback لاستقبال المفتاح
  final Function(ReactionType, GlobalKey?) onSelected;

  const ReactionBubble({required this.onSelected, super.key});

  @override
  State<ReactionBubble> createState() => _ReactionBubbleState();
}

class _ReactionBubbleState extends State<ReactionBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // ✅ قائمة مفاتيح لكل إيموجي عشان نحدد مكانه
  final Map<ReactionType, GlobalKey> _reactionKeys = {
    ReactionType.love: GlobalKey(),
    ReactionType.care: GlobalKey(),
    ReactionType.dislike: GlobalKey(),
  };

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
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
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
              children: [
                _buildReactionItem(ReactionType.love, const Color(0xFFE040FB)),
                _buildReactionItem(ReactionType.care, const Color(0xFFFFD740)),
                _buildReactionItem(
                  ReactionType.dislike,
                  const Color(0xFFFF5252),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReactionItem(ReactionType type, Color baseColor) {
    return GestureDetector(
      onTap: () {
        // ✅ إرسال الريأكشن + المفتاح الخاص به
        widget.onSelected(type, _reactionKeys[type]);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Container(
          width: context.responsiveWidth(45),
          height: context.responsiveWidth(45),
          decoration: BoxDecoration(
            color: baseColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Container(
            // ✅ ربط المفتاح هنا
            key: _reactionKeys[type],
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xff78787880).withOpacity(0.5),
                  blurRadius: 4,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: AppImage(
              getReactionAsset(type),
              fit: BoxFit.contain,
              color: null,
            ),
          ),
        ),
      ),
    );
  }
}
