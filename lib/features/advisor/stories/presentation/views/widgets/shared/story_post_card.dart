import 'package:story_view/story_view.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/my_import.dart';

/// يعرض الـ post داخل الـ story — بدون أي gesture handling
/// التقليب وفتح البوست بيتم عبر الـ gesture layer في story_details_view
class StoryPostCard extends StatelessWidget {
  final PostModel post;
  final StoryController storyController;

  const StoryPostCard({
    super.key,
    required this.post,
    required this.storyController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
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
              // PostCallbacks.empty ensures no video plays inside the story card.
              // Reels inside post cards are intentionally disabled here to prevent
              // audio conflicts with the story video/audio layer.
              // HeroMode disabled to prevent Hero nesting conflicts with the
              // home feed's Hero widgets when this card is kept Offstage by StoryView.
              child: HeroMode(
                enabled: false,
                child: PostCard(
                  post: post,
                  isFromProfile: false,
                  isDetailsView: false,
                  callbacks: PostCallbacks.empty,
                  onNavigateToDetails: null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
