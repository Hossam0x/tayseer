import 'dart:ui';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/my_import.dart';

class ImageViewerGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String? personId;

  const ImageViewerGallery({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.personId,
  });

  @override
  State<ImageViewerGallery> createState() => _ImageViewerGalleryState();
}

class _ImageViewerGalleryState extends State<ImageViewerGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // تم استبدال InteractiveViewer بهذا الويدجت المخصص
              return _ZoomableImage(imageUrl: widget.images[index]);
            },
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildGlassContainer(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.pushNamed(
                            AppRouter.kReportsView,
                            arguments: {
                              'type': ReportType.user,
                              'id': widget.personId,
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.report_gmailerrorred,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildGlassContainer(
              child: SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.images.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentIndex == index ? 10.w : 8.w,
                        height: _currentIndex == index ? 10.w : 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentIndex == index
                              ? const Color(0xFFD84664)
                              : Colors.white54,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 150.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Text(
                "${_currentIndex + 1}\\${widget.images.length}",
                style: Styles.textStyle14.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child}) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(color: Colors.black.withOpacity(0.3), child: child),
      ),
    );
  }
}

// ==========================================
// الويدجت الجديد الخاص بالزوم والـ Double Tap
// ==========================================

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;

  const _ZoomableImage({required this.imageUrl});

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300), // سرعة حركة الزوم
        )..addListener(() {
          _transformationController.value = _animation!.value;
        });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    // تحديد مكان إصبع المستخدم عند الضغط
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    final position = _doubleTapDetails!.localPosition;
    const double scale = 3.0; // مقدار الزوم عند الضغط مرتين

    // حساب إحداثيات التركيز على مكان الضغطة
    final x = -position.dx * (scale - 1);
    final y = -position.dy * (scale - 1);

    Matrix4 endMatrix;

    // إذا كانت الصورة بحجمها الطبيعي -> اعمل زوم ان في مكان الضغطة
    if (_transformationController.value.isIdentity()) {
      endMatrix = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
    }
    // إذا كانت الصورة معملها زوم مسبقاً -> ارجع للحجم الطبيعي
    else {
      endMatrix = Matrix4.identity();
    }

    // تشغيل الأنيميشن لجعل الزوم سلس
    _animation =
        Matrix4Tween(
          begin: _transformationController.value,
          end: endMatrix,
        ).animate(
          CurveTween(curve: Curves.easeInOut).animate(_animationController),
        );

    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 5.0,
        panEnabled: true,
        scaleEnabled: true, // زوم الأصابع (Pinch to zoom) مفعل
        clipBehavior: Clip.none,
        child: Center(
          child: AppImage(
            widget.imageUrl,
            width: context.width,
            height: context.height,
            fit: BoxFit.contain, // لضمان عرض الصورة بالكامل
          ),
        ),
      ),
    );
  }
}
