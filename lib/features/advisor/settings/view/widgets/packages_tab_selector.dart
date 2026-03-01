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

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Horizontal Line (Placed at y=40)
                  Positioned(
                    top: 35.h,
                    left: 0,
                    right: 0,
                    child: Container(height: 5.h, color: Color(0xFFD9D9D9)),
                  ),
                  // Triangles at fixed positions
                  _buildStaticTriangles(sectionWidth),
                  // Selected Indicator (Bubble + Arrow)
                  _buildSelectedIndicator(sectionWidth),
                ],
              );
            },
          ),
        ),
        Gap(10.h),
        // Tab Labels
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabText('Elite', SelectedPackage.elite),
              _buildTabText('Pro', SelectedPackage.pro),
              _buildTabText('Basic', SelectedPackage.basic),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStaticTriangles(double sectionWidth) {
    return Stack(
      children: [
        _buildTriangleAt(sectionWidth * 0.48),
        _buildTriangleAt(sectionWidth * 1.45),
        _buildTriangleAt(sectionWidth * 2.52),
      ],
    );
  }

  Widget _buildTriangleAt(double centerX) {
    return Positioned(
      left: centerX - 10.w,
      top: 35.h,
      child: CustomPaint(
        size: Size(20.w, 15.h),
        painter: TrianglePainter(color: Color(0xFFD9D9D9)),
      ),
    );
  }

  Widget _buildSelectedIndicator(double sectionWidth) {
    int index = 0;
    Color color = AppColors.primary400;
    String label = '';

    if (selectedPackage == SelectedPackage.elite) {
      index = 0;
      color = const Color(0xFFFEC155);
      label = "Elite";
    } else if (selectedPackage == SelectedPackage.pro) {
      index = 1;
      color = const Color(0xFFCF9916);
      label = "Pro";
    } else {
      index = 2;
      color = AppColors.primary400;
      label = "اساسية";
    }

    double centerX = sectionWidth * (index + 0.5);

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
              color: color.withOpacity(0.8),
              borderRadius: BorderRadius.circular(6.r),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
            painter: TrianglePainter(color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabText(String text, SelectedPackage pkg) {
    final isSelected = selectedPackage == pkg;
    return GestureDetector(
      onTap: () => onSelected(pkg),
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: Styles.textStyle16Bold.copyWith(
          color: isSelected ? Colors.black87 : Colors.grey,
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
