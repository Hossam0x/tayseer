import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_custom_controller.dart';
import 'package:tayseer/my_import.dart';

/// 3-zone Instagram-style gesture layer.
/// Left 25% → previous | Center 50% → open post / next | Right 25% → next
/// In Arabic: left=next, right=previous.
class StoryGestureLayer extends StatelessWidget {
  final bool isActive;
  final bool isArabic;
  final bool isPostStory;
  final bool showOpenPostButton;
  final CustomStoryController storyController;

  /// Called with the tap position when center is tapped on a post story.
  final void Function(Offset position) onShowPostButton;
  final VoidCallback onDismissButton;

  const StoryGestureLayer({
    super.key,
    required this.isActive,
    required this.isArabic,
    required this.isPostStory,
    required this.showOpenPostButton,
    required this.storyController,
    required this.onShowPostButton,
    required this.onDismissButton,
  });

  void _next() {
    if (!isActive) return;
    storyController.play();
    storyController.next();
  }

  void _previous() {
    if (!isActive) return;
    storyController.play();
    storyController.previous();
  }

  void _pause() {
    if (isActive) storyController.pause();
  }

  void _resume() {
    if (isActive) storyController.play();
  }

  @override
  Widget build(BuildContext context) {
    final leftAction = isArabic ? _next : _previous;
    final rightAction = isArabic ? _previous : _next;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          // LEFT 25%
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _pause(),
              onTapCancel: _resume,
              onTapUp: (_) {
                onDismissButton();
                leftAction();
              },
            ),
          ),
          // CENTER 50%
          Expanded(
            flex: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _pause(),
              onTapCancel: _resume,
              onTapUp: (details) {
                if (!isActive) return;
                if (showOpenPostButton) {
                  onDismissButton();
                  return;
                }
                if (isPostStory) {
                  onShowPostButton(details.globalPosition);
                  return;
                }
                storyController.play();
                storyController.next();
              },
            ),
          ),
          // RIGHT 25%
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _pause(),
              onTapCancel: _resume,
              onTapUp: (_) {
                onDismissButton();
                rightAction();
              },
            ),
          ),
        ],
      ),
    );
  }
}
