import 'package:tayseer/my_import.dart';

class LifeEventsSection extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final String titleName;

  const LifeEventsSection({
    super.key,
    required this.events,
    required this.titleName,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFE1F5FE), // Light Blue
              Color(0xFFFFFDE7), // Light Yellow/Cream
              Color(0xFFFCE4EC), // Light Pink
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // العنوان
            Padding(
              padding: EdgeInsetsDirectional.only(end: 8.w),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  "${context.tr("goals")} $titleName",
                  style: Styles.textStyle16Bold.copyWith(color: Colors.black),
                ),
              ),
            ),
            Gap(20.h),

            _buildTimelineSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(events.length, (index) {
            return Expanded(
              child: Text(
                events[index]['timeLabel'] ?? '',
                textAlign: TextAlign.center,
                style: Styles.textStyle12.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),

        Gap(10.h),

        SizedBox(
          height: 16.h,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 6.h,
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [HexColor('eb7c92'), HexColor('f2a6b5')],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),

              // النقاط
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(events.length, (index) {
                  return Expanded(
                    child: Center(
                      child: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [HexColor('eb7c92'), HexColor('f2a6b5')],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2.w,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(events.length, (index) {
            final String goalLabel = events[index]['goalLabel'] ?? '';
            return Expanded(
              child: Column(
                children: [
                  CustomPaint(
                    size: Size(12.w, 8.h),
                    painter: TrianglePainter(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      goalLabel,
                      textAlign: TextAlign.center,
                      style: Styles.textStyle14Bold.copyWith(
                        color: AppColors.kscandryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
