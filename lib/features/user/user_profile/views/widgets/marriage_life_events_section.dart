import 'package:tayseer/my_import.dart';

class MarriageLifeEventsSection extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final String titleName;

  const MarriageLifeEventsSection({
    super.key,
    required this.events,
    required this.titleName,
  });

  static const _pink = Color(0xFFF094A5);
  static const _pinkDark = Color(0xFF9E1C36);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          Text(
            titleName,
            style: Styles.textStyle20Bold.copyWith(color: Colors.black87),
          ),
          Gap(20.h),
          _buildTimeline(context),
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(events.length, (i) {
        final isLast = i == events.length - 1;
        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildItem(context, events[i])),
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(top: 28.h),
                  child: SizedBox(
                    width: 12.w,
                    child: Divider(
                      color: _pink.withOpacity(0.5),
                      thickness: 1.5,
                      height: 1,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> event) {
    final timeLabel = event['timeLabel'] as String? ?? '';
    final goalType = event['goalType'] as String? ?? '';

    return Column(
      children: [
        // ── Time label ──
        SizedBox(
          height: 36.h,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                timeLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Styles.textStyle12.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
        Gap(6.h),

        // ── Connector: line + arrowhead pointing to dot ──
        CustomPaint(
          size: Size(2.w, 14.h),
          painter: _ArrowConnectorPainter(color: _pink),
        ),

        // ── Dot ──
        Container(
          width: 14.w,
          height: 14.w,
          decoration: BoxDecoration(
            color: _pink,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: _pink.withOpacity(0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),

        Gap(6.h),

        // ── Goal bubble ──
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
          constraints: BoxConstraints(minHeight: 40.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _getGoalDisplayName(goalType, context),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: Styles.textStyle12Bold.copyWith(
                  color: _pinkDark,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getGoalDisplayName(String goalType, BuildContext context) {
    if (goalType.isEmpty) return '';
    switch (goalType.toLowerCase().trim()) {
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

// ── Arrow connector: vertical line with arrowhead at bottom ──
class _ArrowConnectorPainter extends CustomPainter {
  final Color color;
  const _ArrowConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;

    // Vertical line
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height - 4), paint);

    // Arrowhead
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(cx, size.height)
      ..lineTo(cx - 4, size.height - 6)
      ..lineTo(cx + 4, size.height - 6)
      ..close();

    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
