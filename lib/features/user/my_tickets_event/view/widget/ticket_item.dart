import 'package:tayseer/my_import.dart'; // تأكد إن الـ imports دي مظبوطة عندك

class TicketItem extends StatelessWidget {
  const TicketItem({
    super.key,
    required this.eventTitle,
    required this.location,
    required this.speaker,
    required this.dateTime,
    required this.onPressedDetails,
  });

  final String eventTitle;
  final String location;
  final String speaker;
  final String dateTime;
  final VoidCallback? onPressedDetails;
  @override
  Widget build(BuildContext context) {
    // 1. استخدام CustomPaint عشان نرسم الخلفية والبوردر المخصص
    return CustomPaint(
      painter: TicketPainter(
        borderColor: Colors.pink.shade100, // لون البوردر
        bgColor: Colors.white, // لون الكارت
      ),
      child: Container(
        height: context.responsiveHeight(200),
        padding: const EdgeInsets.all(16), // مسافة عشان المحتوى ميمسش الحواف
        child: Row(
          children: [
            // --- الجزء الأيمن: البيانات (70% من المساحة) ---
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ), // مسافة صغيرة عن الفتحة
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الجلسة
                    RichText(
                      textDirection: TextDirection.rtl,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      text: TextSpan(
                        style: Styles.textStyle16SemiBold,
                        children: [
                          TextSpan(
                            text: context.tr('session_title_ticket'),
                            style: Styles.textStyle14SemiBold,
                          ),
                          TextSpan(
                            text: eventTitle,
                            style: Styles.textStyle16SemiBold.copyWith(
                              color: AppColors.kscandryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // المكان
                    _buildInfoRow(Icons.location_on_outlined, location),

                    // المحاضر
                    _buildInfoRow(Icons.person_outline, speaker),

                    // التاريخ
                    _buildInfoRow(Icons.calendar_today_outlined, dateTime),
                  ],
                ),
              ),
            ),

            // --- فاصل وهمي مكان الفتحة (اختياري) ---
            // SizedBox(width: 10),

            // --- الجزء الأيسر: زر التفاصيل (30% من المساحة) ---
            Expanded(
              flex: 3,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CustomBotton(
                    height: context.responsiveHeight(60),
                    useGradient: true,
                    title: context.tr('details_ticket'),

                    onPressed: onPressedDetails,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت صغيرة للسطر الواحد
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        SizedBox(width: 6),
        Expanded(
          // ضفت Expanded عشان لو النص طويل ماينزلش سطر ويضرب
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Styles.textStyle12.copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}

class MyTicketShimmerItem extends StatelessWidget {
  const MyTicketShimmerItem({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TicketPainter(
        borderColor: Colors.grey.shade300,
        bgColor: Colors.white,
      ),
      child: Container(
        height: context.responsiveHeight(190),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// النصوص
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: double.infinity, height: 16),
                  ShimmerBox(width: double.infinity, height: 12),
                  ShimmerBox(width: double.infinity, height: 12),
                  ShimmerBox(width: 150, height: 12),
                ],
              ),
            ),

            /// الزرار
            Expanded(
              flex: 3,
              child: Center(
                child: ShimmerBox(width: double.infinity, height: 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerBox({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// ---------------------------------------------------------
// الرسام (Painter) بدل الـ Clipper
// ده بيرسم الخلفية + البوردر بيمشي مع الفتحات
// ---------------------------------------------------------
class TicketPainter extends CustomPainter {
  final Color borderColor;
  final Color bgColor;

  TicketPainter({required this.borderColor, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. تجهيز الأقلام
    final Paint bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill; // مليء اللون

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle
          .stroke // رسم خطوط فقط
      ..strokeWidth = 1.8; // سمك البوردر (زي ما طلبت)

    final Paint shadowPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10); // للضل

    // 2. حسابات الأبعاد
    const double cornerRadius = 25.0; // تدويرة الأركان
    const double holeRadius = 15.0; // حجم الفتحة
    // مكان الفتحة: بما أن الزرار واخد flex 3 من 10، يعني 30%
    // لو التطبيق عربي (RTL) الزرار على الشمال، فالفتحة هتكون على بعد 30% من اليسار
    final double cutoutPosition = size.width * 0.30;

    // 3. رسم المسار (Path)
    final Path path = Path();

    // -- ابدأ الرسم --
    // الزاوية العلوية اليسرى
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // الخط العلوي لحد الفتحة
    path.lineTo(cutoutPosition - holeRadius, 0);

    // الفتحة العلوية (نص دايرة لتحت)
    path.arcToPoint(
      Offset(cutoutPosition + holeRadius, 0),
      radius: const Radius.circular(holeRadius),
      clockwise: false,
    );

    // تكملة الخط العلوي للزاوية اليمنى
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // الخط الأيمن
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - cornerRadius,
      size.height,
    );

    // الخط السفلي لحد الفتحة
    path.lineTo(cutoutPosition + holeRadius, size.height);

    // الفتحة السفلية (نص دايرة لفوق)
    path.arcToPoint(
      Offset(cutoutPosition - holeRadius, size.height),
      radius: const Radius.circular(holeRadius),
      clockwise: false,
    );

    // تكملة الخط السفلي للبداية
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);

    path.close(); // قفل الشكل

    // 4. التنفيذ على الكانفاس
    canvas.drawPath(path, shadowPaint); // رسم الضل
    canvas.drawPath(path, bgPaint); // رسم الخلفية البيضاء
    canvas.drawPath(path, borderPaint); // رسم البوردر الوردي فوقهم
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
