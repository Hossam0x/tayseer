import 'package:tayseer/my_import.dart';

class LifeEventsSection extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const LifeEventsSection({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: Column(
        children: [
          Text("أحداث الحياة ومساري", style: Styles.textStyle14Bold),
          Gap(15.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildTimeline(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeline() {
    List<Widget> timelineWidgets = [];
    for (int i = 0; i < events.length; i++) {
      timelineWidgets.add(
        _buildTimePoint(events[i]['label'], events[i]['isActive']),
      );
      if (i < events.length - 1) {
        timelineWidgets.add(
          Expanded(
            child: Container(height: 2.h, color: Colors.pink.shade200),
          ),
        );
      }
    }
    return timelineWidgets;
  }

  Widget _buildTimePoint(String text, bool isActive) {
    return Column(
      children: [
        CircleAvatar(
          radius: 6.r,
          backgroundColor: isActive ? Colors.pink : Colors.grey.shade300,
        ),
        Gap(5.h),
        Text(
          text,
          style: isActive
              ? Styles.textStyle12SemiBold.copyWith(color: Colors.pink)
              : Styles.textStyle12,
        ),
      ],
    );
  }
}
