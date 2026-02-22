import 'package:tayseer/features/shared/event/view/widget/custom_sliver_app_bar.dart';
import 'package:tayseer/features/user/my_tickets_event/view/widget/ticket_item.dart';
import 'package:tayseer/my_import.dart'; // تأكد من الـ imports بتاعتك

class MyTicketsBody extends StatelessWidget {
  const MyTicketsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: CustomScrollView(
        slivers: [
          // 1. الهيدر اللي صلحناه سابقاً
          const CustomSliverAppBarEvent(title: "تذكرتي", showBackButton: true),

          // 2. قائمة التذاكر
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveWidth(16),
              vertical: context.responsiveHeight(20),
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: TicketItem(
                    eventTitle: "جلسة : تحسين مهارات التواصل",
                    location: "نادي المهندسين , دمياط الجديدة , مصر",
                    speaker: "مستشار / علي عباس",
                    dateTime: "يوم 13 يناير 2024 الساعة 5:00 Am",
                    onPressedDetails: () {
                      debugPrint("تفاصيل التذكرة $index");
                    },
                  ),
                );
              }, childCount: 4),
            ),
          ),
        ],
      ),
    );
  }
}
