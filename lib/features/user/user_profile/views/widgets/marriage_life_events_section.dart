// marriage_life_events_section.dart - FIXED VERSION
// ════════════════════════════════════════════════════════════════
// ✅ FIX: استخدام goalType بدل goalLabel للترجمة الصحيحة
// ════════════════════════════════════════════════════════════════

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 24.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFD3EFFF), // Soft Blue
            Color(0xFFFFF9E3), // Soft Yellow
            Color(0xFFFFE1EA), // Soft Pink
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
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              titleName,
              style: Styles.textStyle20Bold.copyWith(color: Colors.black87),
            ),
          ),
          Gap(25.h),
          _buildTimelineSection(context),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(context) {
    return Column(
      children: [
        // 1. Time Labels (Top) - الفترة الزمنية
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

        // 2. The Timeline Line and Nodes
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The solid pink line
              Container(
                height: 4.h,
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF094A5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // The circular dots
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: events.map((event) {
                  return Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF094A5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
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

        // 3. Goal Labels (Bottom Bubbles) - الهدف الفعلي
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: events.map((event) {
              return Expanded(
                child: Column(
                  children: [
                    // Little pointer triangle
                    CustomPaint(
                      size: Size(12.w, 6.h),
                      painter: TrianglePainter(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    // Rounded pill container
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      padding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 12.w,
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
                          // ⭐⭐⭐ استخدام goalType للترجمة الصحيحة
                          _getGoalDisplayName(event['goalType'], context),
                          style: Styles.textStyle14Bold.copyWith(
                            color: const Color(0xFF9E1C36),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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

  // ⭐⭐⭐ FIXED: Convert goal type to display name
  String _getGoalDisplayName(String? goalType, BuildContext context) {
    if (goalType == null || goalType.isEmpty) return '';
    
    final normalized = goalType.toLowerCase().trim();
    
    switch (normalized) {
      case 'engagement':
        return context.tr('engagement_profile');
      case 'marry':
      case 'marriage':
        return context.tr('marriage_profile');
      case 'familyacceptance':
      case 'children':
        return context.tr('children_profile');
      case 'travel':
        return context.tr('travel_profile');
      default:
        // If it's already a translated value, return as-is
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
    path.moveTo(size.width / 2, 0); // Tip of triangle
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}