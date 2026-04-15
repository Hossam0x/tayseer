import 'package:story_view/story_view.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/my_import.dart';

/// ✅ يعرض الـ post داخل الـ story
/// بيبلغ الـ parent بالـ bounds الفعلية للـ PostCard عبر [onCardBoundsReady]
/// عشان الـ parent يحط tap handler بالظبط فوق الـ PostCard
class StoryPostCard extends StatefulWidget {
  final PostModel post;
  final StoryController storyController;
  final void Function(Rect bounds)? onCardBoundsReady;

  const StoryPostCard({
    super.key,
    required this.post,
    required this.storyController,
    this.onCardBoundsReady,
  });

  @override
  State<StoryPostCard> createState() => _StoryPostCardState();
}

class _StoryPostCardState extends State<StoryPostCard> {
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // بعد ما الـ widget يتبني، نحسب الـ bounds ونبلغ الـ parent
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportBounds());
  }

  void _reportBounds() {
    if (!mounted || widget.onCardBoundsReady == null) return;
    final ctx = _cardKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final offset = box.localToGlobal(Offset.zero);
    final rect = offset & box.size;
    widget.onCardBoundsReady!(rect);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            key: _cardKey,
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 60.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: PostCard(
                post: widget.post,
                isFromProfile: false,
                isDetailsView: false,
                callbacks: PostCallbacks.empty,
                onNavigateToDetails: null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
