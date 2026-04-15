import 'package:story_view/story_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Custom Story Controller — guards play() so inactive pages can't play
// ─────────────────────────────────────────────────────────────────────────────
class CustomStoryController extends StoryController {
  bool isAllowedToPlay = false;

  @override
  void play() {
    if (isAllowedToPlay) {
      super.play();
    }
  }
}
