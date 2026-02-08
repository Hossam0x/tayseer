import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/my_import.dart';

class StoryPreviewView extends StatelessWidget {
  final File file;
  final VoidCallback onClose;
  const StoryPreviewView({
    super.key,
    required this.file,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen image
        Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),

        // Header with Publish and Back button
        Positioned(
          top: 40.h,
          left: 16.w,
          right: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => context.pop(),
              ),
              CustomBotton(
                width: 100.w,
                height: 40.h,
                title: context.tr('to_publish'),
                useGradient: true,
                onPressed: () => context.read<AddStoryCubit>().createStory(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
