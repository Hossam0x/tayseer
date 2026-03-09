import 'package:tayseer/features/advisor/settings/view_model/packages_cubit.dart';
import 'package:tayseer/my_import.dart';

class PackagesTabSelector extends StatelessWidget {
  final SelectedPackage selectedPackage;
  final ValueChanged<SelectedPackage> onSelected;

  const PackagesTabSelector({
    super.key,
    required this.selectedPackage,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final sectionWidth = width / 3;
              final bool isEliteSelected =
                  selectedPackage == SelectedPackage.elite;
              final Color barColor = isEliteSelected
                  ? Colors.white
                  : const Color(0xFFD9D9D9);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Horizontal Line (Placed at y=40)
                  Positioned(
                    top: 35.h,
                    left: 0,
                    right: 0,
                    child: Container(height: 5.h, color: barColor),
                  ),
                  // Triangles at fixed positions
                  _buildStaticTriangles(sectionWidth, barColor),
                  // Selected Indicator (Bubble + Arrow)
                  _buildSelectedIndicator(sectionWidth),
                  // Interactive Overlay for the top part
                  Row(
                    children: [
                      _buildTopClickOverlay(SelectedPackage.elite),
                      _buildTopClickOverlay(SelectedPackage.pro),
                      _buildTopClickOverlay(SelectedPackage.basic),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        Gap(10.h),
        // Tab Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabText('Elite', SelectedPackage.elite),
            _buildTabText('Pro', SelectedPackage.pro),
            _buildTabText('Basic', SelectedPackage.basic),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticTriangles(double sectionWidth, Color color) {
    return Stack(
      children: [
        _buildTriangleAt(
          isArabic ? sectionWidth * 0.52 : sectionWidth * 0.48,
          color,
        ),
        _buildTriangleAt(sectionWidth * 1.49, color),
        _buildTriangleAt(
          isArabic ? sectionWidth * 2.48 : sectionWidth * 2.52,
          color,
        ),
      ],
    );
  }

  Widget _buildTriangleAt(double centerX, Color color) {
    return Positioned(
      left: centerX - 10.w,
      top: 35.h,
      child: CustomPaint(
        size: Size(20.w, 15.h),
        painter: TrianglePainter(color: color),
      ),
    );
  }

  Widget _buildSelectedIndicator(double sectionWidth) {
    int index = 0;
    List<Color> colors = [AppColors.primary400, AppColors.primary400];
    String label = '';
    bool isVertical = true;

    if (selectedPackage == SelectedPackage.elite) {
      index = 0;
      colors = [const Color(0xFF4BB8F9), const Color(0xFF6284FF)];
      label = "مميزة";
    } else if (selectedPackage == SelectedPackage.pro) {
      index = 1;
      colors = [const Color(0xFFBD8F14), const Color(0xFFF5C003)];
      label = "ذهبية";
      isVertical = false;
    } else {
      index = 2;
      colors = [AppColors.primary300, AppColors.primary500];
      label = "أساسية";
    }

    final int visualIndex = isArabic ? (2 - index) : index;
    double centerX = sectionWidth * (visualIndex + 0.5);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: centerX - 36.w,
      top: 0,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: isVertical ? Alignment.topCenter : Alignment.centerRight,
                end: isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: colors.last.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              label,
              style: Styles.textStyle16SemiBold.copyWith(color: Colors.white),
            ),
          ),
          CustomPaint(
            size: Size(15.w, 10.h),
            painter: TrianglePainter(colors: colors, isVertical: isVertical),
          ),
        ],
      ),
    );
  }

  Widget _buildTopClickOverlay(SelectedPackage pkg) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(pkg),
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildTabText(String text, SelectedPackage pkg) {
    final bool isEliteSelected = selectedPackage == SelectedPackage.elite;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(pkg),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            text,
            style: Styles.textStyle16.copyWith(
              color: isEliteSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final List<Color>? colors;
  final Color? color;
  final bool isVertical;

  TrianglePainter({this.colors, this.color, this.isVertical = true});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..style = PaintingStyle.fill;

    if (colors != null) {
      paint.shader = LinearGradient(
        colors: colors!,
        begin: isVertical ? Alignment.topCenter : Alignment.centerRight,
        end: isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else if (color != null) {
      paint.color = color!;
    }

    var path = Path();
    const double radius = 2.0;

    // Drawing a rounded triangle (pointing down)
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(size.width / 2 + radius, size.height - radius);
    path.arcToPoint(
      Offset(size.width / 2 - radius, size.height - radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius));

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isVertical != isVertical ||
        oldDelegate.colors != colors;
  }
}
