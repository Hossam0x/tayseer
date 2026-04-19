import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_card.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';

/// شاشة تعديل الـ story قبل النشر.
/// الخلفية (gradient) بتتحول لصورة، وبعدين الـ post بيتضاف كـ WidgetLayer
/// تفاعلي جوه الـ ProImageEditor — يتحرك، يكبر، يصغر، ويلف زي الـ text sticker.
class StoryPostEditorView extends StatefulWidget {
  final PostModel post;

  const StoryPostEditorView({super.key, required this.post});

  @override
  State<StoryPostEditorView> createState() => _StoryPostEditorViewState();
}

class _StoryPostEditorViewState extends State<StoryPostEditorView> {
  final GlobalKey _bgRepaintKey = GlobalKey();
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureBackground());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // الخلفية المخفية — gradient فقط بدون الـ post
          Positioned(
            left: -9999,
            top: 0,
            child: RepaintBoundary(
              key: _bgRepaintKey,
              child: _GradientBackground(),
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

  Future<void> _captureBackground() async {
    if (_isCapturing) return;
    _isCapturing = true;

    try {
      await Future.delayed(const Duration(milliseconds: 200));

      final boundary =
          _bgRepaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null || !mounted) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null || !mounted) return;

      final bytes = byteData.buffer.asUint8List();
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              _StoryEditorScreen(backgroundBytes: bytes, post: widget.post),
        ),
      );
    } catch (e) {
      debugPrint('StoryPostEditorView capture error: $e');
      if (mounted) Navigator.pop(context);
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// خلفية الـ story — gradient فقط بدون الـ post (9:16)
// ══════════════════════════════════════════════════════════════════════════════
class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      height: 693,
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
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// شاشة الـ Editor — ProImageEditor + الـ post كـ WidgetLayer تفاعلي
// ══════════════════════════════════════════════════════════════════════════════
class _StoryEditorScreen extends StatefulWidget {
  final Uint8List backgroundBytes;
  final PostModel post;

  const _StoryEditorScreen({required this.backgroundBytes, required this.post});

  @override
  State<_StoryEditorScreen> createState() => _StoryEditorScreenState();
}

class _StoryEditorScreenState extends State<_StoryEditorScreen> {
  final _editorKey = GlobalKey<ProImageEditorState>();

  /// عدد الأصابع اللي لامسة الشاشة
  int _pointerCount = 0;

  /// آخر وقت طلعنا فيه haptic feedback
  DateTime? _lastHapticTime;

  /// الفترة الأدنى بين كل haptic feedback (milliseconds)
  static const int _hapticInterval = 100;

  void _onPointerDown(PointerDownEvent event) {
    setState(() {
      _pointerCount++;
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    setState(() {
      _pointerCount--;
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    // نشتغل بس لما يكون فيه إصبعين أو أكتر (pinch gesture)
    if (_pointerCount >= 2) {
      final now = DateTime.now();

      // نتأكد إن مر وقت كافي من آخر haptic feedback
      if (_lastHapticTime == null ||
          now.difference(_lastHapticTime!).inMilliseconds >= _hapticInterval) {
        HapticFeedback.lightImpact();
        _lastHapticTime = now;
      }
    }
  }

  /// بعد ما الـ editor يتجهز، نضيف الـ post كـ WidgetLayer في المنتصف.
  /// الـ scale بيتحسب عشان الـ post يملأ عرض الـ editor تقريباً زي ما كان
  /// في الـ canvas الأصلي — بدون تصغير.
  void _onEditorReady() {
    final editorState = _editorKey.currentState;
    if (editorState == null) return;

    // عرض الـ editor = عرض الشاشة
    final screenWidth = MediaQuery.sizeOf(context).width;
    // الـ post widget عرضه 340 logical pixels
    // نحسب الـ scale عشان يملأ ~90% من عرض الـ editor
    final scale = (screenWidth * 2.5) / 340.0;

    editorState.addLayer(
      WidgetLayer(
        widget: _PostCardWidget(post: widget.post),
        scale: scale,
      ),
    );
  }

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
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerMove: _onPointerMove,
      child: ProImageEditor.memory(
        widget.backgroundBytes,
        key: _editorKey,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: _onEditingComplete,
          onCloseEditor: (_) => Navigator.pop(context),
          mainEditorCallbacks: MainEditorCallbacks(
            onAfterViewInit: _onEditorReady,
          ),
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
                    onPressed: _closeEditor,
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
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// الـ PostCard المغلف — بيتضاف كـ WidgetLayer جوه الـ editor
// ══════════════════════════════════════════════════════════════════════════════
class _PostCardWidget extends StatefulWidget {
  final PostModel post;

  const _PostCardWidget({required this.post});

  @override
  State<_PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<_PostCardWidget> {
  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: false,
      child: SizedBox(
        width: 340,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PostCard(
            post: widget.post,
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
    );
  }
}
