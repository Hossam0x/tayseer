import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';

class PackageTabSelector extends StatelessWidget {
  final PackageType selectedPackage;
  final ValueChanged<PackageType> onSelected;

  const PackageTabSelector({
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
              final sectionWidth = constraints.maxWidth / 3;
              final isEliteSelected = selectedPackage == PackageType.elite;
              final barColor = isEliteSelected
                  ? Colors.white
                  : const Color(0xFFD9D9D9);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildHorizontalLine(barColor),
                  _buildStaticTriangles(sectionWidth, barColor),
                  _buildSelectedIndicator(sectionWidth),
                  _buildClickableOverlays(),
                ],
              );
            },
          ),
        ),
        Gap(10.h),
        _buildTabLabels(),
      ],
    );
  }

  Widget _buildHorizontalLine(Color color) {
    return Positioned(
      top: 35.h,
      left: 0,
      right: 0,
      child: Container(height: 5.h, color: color),
    );
  }

  Widget _buildStaticTriangles(double sectionWidth, Color color) {
    return Stack(
      children: [
        _buildTriangleAt(
          isArabic ? sectionWidth * 0.48 : sectionWidth * 0.52,
          color,
        ),
        _buildTriangleAt(sectionWidth * 1.49, color),
        _buildTriangleAt(
          isArabic ? sectionWidth * 2.52 : sectionWidth * 2.48,
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
        painter: _TrianglePainter(color: color),
      ),
    );
  }

  Widget _buildSelectedIndicator(double sectionWidth) {
    final config = _getPackageConfig(selectedPackage);
    // Same visual order for all languages: Basic (2) -> Pro (1) -> Elite (0)
    // In RTL, the visual position is reversed but the index stays the same
    final visualIndex = isArabic ? (2 - config.index) : config.index;
    final centerX = sectionWidth * (visualIndex + 0.5);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      left: centerX - 36.w,
      top: 0,
      child: Column(
        children: [
          _buildBubble(config),
          CustomPaint(
            size: Size(15.w, 10.h),
            painter: _TrianglePainter(
              colors: config.colors,
              isVertical: config.isVertical,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(_PackageConfig config) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.colors,
          begin: config.isVertical
              ? Alignment.topCenter
              : Alignment.centerRight,
          end: config.isVertical
              ? Alignment.bottomCenter
              : Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: config.colors.last.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        config.label,
        style: Styles.textStyle16SemiBold.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildClickableOverlays() {
    return Row(
      children: [
        // Same order for all languages: Basic -> Pro -> Elite
        _buildClickOverlay(PackageType.basic),
        _buildClickOverlay(PackageType.pro),
        _buildClickOverlay(PackageType.elite),
      ],
    );
  }

  Widget _buildClickOverlay(PackageType packageType) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(packageType),
        behavior: HitTestBehavior.opaque,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildTabLabels() {
    final isEliteSelected = selectedPackage == PackageType.elite;
    final textColor = isEliteSelected ? Colors.white : Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Same order for all languages: Basic -> Pro -> Elite
        _buildTabText('Basic', PackageType.basic, textColor),
        _buildTabText('Pro', PackageType.pro, textColor),
        _buildTabText('Elite', PackageType.elite, textColor),
      ],
    );
  }

  Widget _buildTabText(String text, PackageType packageType, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(packageType),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(text, style: Styles.textStyle16.copyWith(color: color)),
        ),
      ),
    );
  }

  _PackageConfig _getPackageConfig(PackageType packageType) {
    // Index represents visual position: Basic (0) -> Pro (1) -> Elite (2)
    switch (packageType) {
      case PackageType.basic:
        return _PackageConfig(
          index: 0,
          colors: [AppColors.primary300, AppColors.primary500],
          label: "أساسية",
          isVertical: true,
        );
      case PackageType.pro:
        return _PackageConfig(
          index: 1,
          colors: const [Color(0xFFBD8F14), Color(0xFFF5C003)],
          label: "ذهبية",
          isVertical: false,
        );
      case PackageType.elite:
        return _PackageConfig(
          index: 2,
          colors: const [Color(0xFF4BB8F9), Color(0xFF6284FF)],
          label: "مميزة",
          isVertical: true,
        );
    }
  }
}

class _PackageConfig {
  final int index;
  final List<Color> colors;
  final String label;
  final bool isVertical;

  _PackageConfig({
    required this.index,
    required this.colors,
    required this.label,
    required this.isVertical,
  });
}

class _TrianglePainter extends CustomPainter {
  final List<Color>? colors;
  final Color? color;
  final bool isVertical;

  _TrianglePainter({this.colors, this.color, this.isVertical = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (colors != null) {
      paint.shader = LinearGradient(
        colors: colors!,
        begin: isVertical ? Alignment.topCenter : Alignment.centerRight,
        end: isVertical ? Alignment.bottomCenter : Alignment.centerLeft,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else if (color != null) {
      paint.color = color!;
    }

    final path = Path();
    const radius = 2.0;

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
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isVertical != isVertical ||
        oldDelegate.colors != colors;
  }
}
