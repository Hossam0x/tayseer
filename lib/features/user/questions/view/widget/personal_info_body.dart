import 'dart:math' as math;

import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';
import 'dart:ui' as ui; // For the dashed border

class PersonalInfoBody extends StatefulWidget {
  const PersonalInfoBody({super.key});

  @override
  State<PersonalInfoBody> createState() => _PersonalInfoBodyState();
}

class _PersonalInfoBodyState extends State<PersonalInfoBody> {
  final ImagePicker _picker = ImagePicker();

  final int maxSecondaryImages = 4;

  List<File> images = [];
  File? mainImage;

  Future<void> pickImage() async {
    if (images.length >= maxSecondaryImages) return;
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      images.add(File(picked.path));
    });
  }

  Future<void> pickMainImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() {
      mainImage = File(picked.path);
    });
  }

  void removeImage(int index) {
    setState(() => images.removeAt(index));
  }

  void removeMainImage() {
    setState(() => mainImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                SizedBox(height: context.height * 0.05),

                Row(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    Text(
                      context.tr('add_your_personal_details'),
                      style: Styles.textStyle20.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.kscandryTextColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // --- THE NEW UNIFIED GRID ---
                Directionality(
                  textDirection: TextDirection
                      .rtl, // Enforce RTL to match the screenshot layout
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // 3 Columns
                          childAspectRatio: 0.7, // Taller cards
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ImageSlotCard(
                          image: mainImage,
                          isMain: true,
                          onTap: pickMainImage,
                          onRemove: removeMainImage,
                        );
                      }

                      if (index == 5) {
                        return const SizedBox();
                      }

                      int listIndex = index - 1;

                      if (listIndex < images.length) {
                        // Show selected image
                        return ImageSlotCard(
                          image: images[listIndex],
                          isMain: false,
                          onTap: () {}, // Already selected
                          onRemove: () => removeImage(listIndex),
                        );
                      } else {
                        return ImageSlotCard(
                          image: null,
                          isMain: false,
                          onTap: pickImage,
                        );
                      }
                    },
                  ),
                ),

                SizedBox(height: context.height * 0.05),

                // Action Button
                BlocConsumer<QuestionsCubit, QuestionsState>(
                  listener: (context, state) {
                    if (state.uploadPersonalInfoState == CubitStates.success) {
                      context.pop(); // Close loading dialog if open
                      setState(() {
                        images.clear();
                        mainImage = null;
                      });
                      context.pushNamed(AppRouter.kFaceVerificationView);
                    } else if (state.uploadPersonalInfoState ==
                        CubitStates.failure) {
                      context.pop(); // Close loading dialog if open
                      ScaffoldMessenger.of(context).showSnackBar(
                        CustomSnackBar(context, text: state.errorMessage ?? ''),
                      );
                    } else if (state.uploadPersonalInfoState ==
                        CubitStates.loading) {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            const Center(child: CustomloadingApp()),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isloading =
                        state.uploadPersonalInfoState == CubitStates.loading;
                    bool isValid = mainImage != null;

                    return CustomBotton(
                      backGroundcolor: AppColors.kgreyColor,
                      useGradient: isValid,
                      width: context.width,
                      title: isloading
                          ? context.tr('sending')
                          : context.tr('next'),
                      onPressed: isValid
                          ? () {
                              if (!isloading) {
                                getIt<QuestionsCubit>().uploadPersonalInfo(
                                  image: mainImage,
                                  images: images,
                                );
                              }
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- CUSTOM WIDGETS ----------------

class ImageSlotCard extends StatelessWidget {
  final File? image;
  final bool isMain;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const ImageSlotCard({
    super.key,
    this.image,
    this.isMain = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: image == null ? onTap : null, // Only pick if empty
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background / Border
          if (image == null)
            CustomPaint(
              painter: DashedRectPainter(
                color: AppColors.kbinkColor,
                strokeWidth: 1.5,
                gap: 5.0,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // No color, transparent
                ),
                child: Center(
                  child: Icon(Icons.add, size: 32, color: AppColors.kbinkColor),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                image: DecorationImage(
                  image: FileImage(image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Main Image Label (Only if isMain)
          if (isMain)
            Positioned(
              bottom: 2,
              right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HexColor('b11b39'),
                  borderRadius: BorderRadius.circular(8),
                ),

                child: Text(
                  "الصورة الرئيسية",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10, // Small text like design
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Remove Button (Only if image exists)
          if (image != null)
            Positioned(
              top: 4,
              left: 4, // Left because RTL
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------- UTILS: Dashed Border Painter ----------------
class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.grey,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );

    Path dashPath = Path();
    double dashWidth = 6.0;
    double dashSpace = gap;
    double distance = 0.0;

    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth;
        distance += dashSpace;
      }
    }
    canvas.drawPath(dashPath, dashedPaint);
  }

  Path getDashedPath({
    required math.Point<double> a,
    required math.Point<double> b,
    @required double? gap,
  }) {
    Size size = Size(b.x - a.x, b.y - a.y);
    Path path = Path();
    path.moveTo(a.x, a.y);
    bool shouldDraw = true;
    math.Point currentPoint = math.Point(a.x, a.y);

    num radians = math.atan(size.height / size.width);

    num dx = math.cos(radians) * gap! < 0
        ? math.cos(radians) * gap * -1
        : math.cos(radians) * gap;

    num dy = math.sin(radians) * gap < 0
        ? math.sin(radians) * gap * -1
        : math.sin(radians) * gap;

    while (currentPoint.x <= b.x && currentPoint.y <= b.y) {
      shouldDraw
          ? path.lineTo(currentPoint.x as double, currentPoint.y as double)
          : path.moveTo(currentPoint.x as double, currentPoint.y as double);
      shouldDraw = !shouldDraw;
      currentPoint = math.Point(currentPoint.x + dx, currentPoint.y + dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
