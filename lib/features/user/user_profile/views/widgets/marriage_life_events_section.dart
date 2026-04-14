import 'package:tayseer/my_import.dart';

class MarriageLifeEventsSection extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final String titleName;

  const MarriageLifeEventsSection({
    super.key,
    required this.events,
    required this.titleName,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFD3EFFF),
            Color(0xFFFFF9E3),
            Color(0xFFFFE1EA),
          ],
        ),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 9.w),
            child: Directionality(
              // ✅ التغيير الأول: عربي → أهداف + اسم | إنجليزي → اسم + أهداف
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Text(
                titleName,
                style: Styles.textStyle20Bold.copyWith(color: Colors.black87),
              ),
            ),
          ),
          Gap(25.h),
          _buildTimelineSection(context),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return Column(
      children: [
        // 1. Time Labels (Top)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: events.map((event) {
              return Expanded(
                child: Center(
                  child: Text(
                    event['timeLabel'] ?? '',
                    textAlign: TextAlign.center,
                    style: Styles.textStyle12.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Gap(8.h),

        // 2. Timeline Line and Nodes
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 4.h,
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF094A5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: events.map((event) {
                  return Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF094A5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF094A5).withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Gap(6.h),

        // 3. Goal Labels (Bottom Bubbles)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: events.map((event) {
              return Expanded(
                child: Column(
                  children: [
                    CustomPaint(
                      size: Size(12.w, 6.h),
                      painter: TrianglePainter(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 6.w, // ✅ قللنا الـ horizontal عشان النص يتسع
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getGoalDisplayName(event['goalType'], context),
                          style: Styles.textStyle12Bold.copyWith(
                            color: const Color(0xFF9E1C36),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,        // ✅ التغيير الثاني
                          maxLines: 4,           // ✅ زيادة من 2 لـ 3
                          overflow: TextOverflow.visible, // ✅ بدل ellipsis
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getGoalDisplayName(String? goalType, BuildContext context) {
    if (goalType == null || goalType.isEmpty) return '';

    final normalized = goalType.toLowerCase().trim();

    switch (normalized) {
      case 'engagement':
        return context.tr('engagement_profile');
      case 'marriage_intentions':
      case 'marriage':
        return context.tr('marriage_profile');
      case 'familyacceptance':
        return context.tr('children_profile');
      case 'intendtravelabroad':
        return context.tr('travel_profile');
      default:
        return goalType;
    }
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
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}