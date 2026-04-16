import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';

/// شاشة تعديل الـ story قبل النشر — بتعرض الـ post كـ widget مصغر
/// على خلفية gradient، وتفتح ProImageEditor للتعديل (نص، ستيكرز، إلخ)
class StoryPostEditorView extends StatefulWidget {
  final PostModel post;

  const StoryPostEditorView({super.key, required this.post});

  @override
  State<StoryPostEditorView> createState() => _StoryPostEditorViewState();
}

class _StoryPostEditorViewState extends State<StoryPostEditorView> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _captureAndOpenEditor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // الـ widget المخفي اللي هيتحول لصورة
          Positioned(
            left: -9999,
            top: 0,
            child: RepaintBoundary(
              key: _repaintKey,
              child: _PostStoryCanvas(post: widget.post),
            ),
          ),
          // شاشة التحميل
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                Gap(16.h),
                Text(
                  context.tr('preparing_story_editor'),
                  style: Styles.textStyle14.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndOpenEditor() async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null || !mounted) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null || !mounted) return;

      final bytes = byteData.buffer.asUint8List();
      if (!mounted) return;

      // push عادي — الـ stack يبقى: Home → StoryPostEditorView → _StoryEditorScreen
      // لما ينشر: pop مرتين → يرجع للـ Home
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _StoryEditorScreen(imageBytes: bytes, post: widget.post),
        ),
      );
    } catch (e) {
      debugPrint('StoryPostEditorView capture error: $e');
      if (mounted) Navigator.pop(context);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Canvas — الـ post على خلفية gradient بحجم story (9:16)
// ══════════════════════════════════════════════════════════════════════════════
class _PostStoryCanvas extends StatelessWidget {
  final PostModel post;

  const _PostStoryCanvas({required this.post});

  @override
  Widget build(BuildContext context) {
    const double w = 390;
    const double h = 693;

    return SizedBox(
      width: w,
      height: h,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.kprimaryColor.withOpacity(0.9),
              AppColors.kprimaryColor.withOpacity(0.4),
              Colors.black87,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PostCard(
                post: post,
                isFromProfile: false,
                isDetailsView: false,
                callbacks: PostCallbacks.empty,
                onNavigateToDetails: null,
                hideActions: true,
                hideHeaderMeta: true,
                mediaMaxHeight: 400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// شاشة الـ Editor الفعلية — ProImageEditor على الصورة المولدة
// ══════════════════════════════════════════════════════════════════════════════
class _StoryEditorScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final PostModel post;

  const _StoryEditorScreen({required this.imageBytes, required this.post});

  @override
  State<_StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<_StoryEditorScreen> {
  /// إغلاق بدون نشر — pop مرتين للرجوع للـ Home
  void _closeEditor() {
    if (!mounted) return;
    final nav = Navigator.of(context);
    nav.pop(); // يشيل _StoryEditorScreen
    nav.pop(); // يشيل StoryPostEditorView
  }

  Future<void> _onEditingComplete(Uint8List editedBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/story_post_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(editedBytes);

      if (!mounted) return;

      // ابعت الصورة كـ story
      getIt<StoriesCubit>().createStory(
        images: [file],
        postId: widget.post.postId,
        context: context,
      );

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Story publish error: $e');
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.memory(
      widget.imageBytes,
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: _onEditingComplete,
        onCloseEditor: (_) => Navigator.pop(context),
      ),
      configs: ProImageEditorConfigs(
        i18n: I18n(done: context.tr('to_publish')),
        designMode: ImageEditorDesignMode.material,
        imageGeneration: const ImageGenerationConfigs(
          outputFormat: OutputFormat.jpg,
          jpegQuality: 95,
        ),
        mainEditor: MainEditorConfigs(
          enableZoom: true,
          widgets: MainEditorWidgets(
            appBar: (editor, rebuildStream) => ReactiveAppbar(
              stream: rebuildStream,
              builder: (_) => AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _closeEditor(),
                ),
                title: Text(
                  context.tr('edit_story'),
                  style: Styles.textStyle16SemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    child: CustomBotton(
                      width: 100.w,
                      height: 35.h,
                      title: context.tr('to_publish'),
                      useGradient: true,
                      titleColor: Colors.white,
                      onPressed: () => editor.doneEditing(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
