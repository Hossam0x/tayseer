import 'package:tayseer/my_import.dart';

class StatusRibbonwidget extends StatelessWidget {
  const StatusRibbonwidget({
    super.key,
    required this.statusText,
    required this.topTextPosition,
    required this.rightTextPosition,
  });
  final String statusText;
  final double topTextPosition;
  final double rightTextPosition;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: [
        // المثلث الصغير (Vector 4) الذي يظهر الالتفاف الخلفي
        Positioned(
          // top: 3.h,
          left: 0, // المسافة تعتمد على طول الشريط
          child: AppImage(AssetsData.vector4, width: 10.w, height: 9.h),
        ),

        // الشريط الوردي (Vector 3) مع النص
        SizedBox(
          width: 100.w,
          height: 100.w,
          child: Stack(
            children: [
              AppImage(
                AssetsData.sentGreetingRibbon, // صورة الشريط الوردي فقط بدون نص
                width: 100.w,
              ),
              // النص مكتوب برمجياً لضمان الجودة
              Positioned(
                top:topTextPosition,
                // bottom: 33.h,
                right: rightTextPosition,
                child: Transform.rotate(
                  angle: 0.78, // زاوية ميل 45 درجة تقريباً
                  child: Stack(
                    children: [
                      // Text with stroke (border)
                      Text(
                        statusText,
                        style: Styles.textStyle14Bold.copyWith(
                          fontWeight: FontWeight.w900,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 3
                                .w // عرض الحد
                            ..color = AppColors.primary300,
                        ),
                      ),
                      // Text with fill (النص الأساسي)
                      Text(
                        statusText,
                        style: Styles.textStyle14Bold.copyWith(
                          color: Color(
                            0xffFFFFFF,
                          ), // نفس لون الشريط أو أي لون تريده
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
