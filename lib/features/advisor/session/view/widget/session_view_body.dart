import 'package:tayseer/core/enum/session_card_style.dart';
import 'package:tayseer/features/advisor/session/view/widget/session_card.dart';
import 'package:tayseer/my_import.dart';

class SessionViewBody extends StatefulWidget {
  const SessionViewBody({super.key});

  @override
  State<SessionViewBody> createState() => _SessionViewBodyState();
}

class _SessionViewBodyState extends State<SessionViewBody> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                context.tr("coming"),
                style: Styles.textStyle16SemiBold,
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index == 0) {
                  return SessionCard(
                    isBlur: true,
                    sessiondate: "2024-10-12 10:00 AM",
                    timeRange: "10:00 AM - 11:00 AM",
                    imageUrl: 'https://i.pravatar.cc/150?img=12',
                    style: SessionCardStyle.active,
                    name: "أحمد منصور",
                    handle: "@fdtgsyhujkl",
                    buttonText: "انضمام",
                  );
                }
                return SessionCard(
                  onTapDetails: () {
                    context.pushNamed(AppRouter.kSessionDetailsView);
                  },
                  isBlur: false,
                  sessiondate: "2024-10-12 10:00 AM",
                  timeRange: "10:00 AM - 11:00 AM",
                  imageUrl: 'https://i.pravatar.cc/150?img=12',
                  style: SessionCardStyle.outlined,
                  name: "أحمد منصور",
                  handle: "@fdtgsyhujkl",
                  buttonText: "التفاصيل",
                );
              },
              childCount: 3, // عدد العناصر في القائمة الأولى
            ),
          ),

          // --- عنوان القائمة الثانية ---
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(right: 20),
              child: Text(
                context.tr("previous_sessions"),
                style: Styles.textStyle16SemiBold,
              ),
            ),
          ),

          // --- قائمة الجلسات السابقة (SliverList) ---
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return SessionCard(
                onTapDetails: () {
                  context.pushNamed(AppRouter.kSessionDetailsView);
                },
                isBlur: true,
                sessiondate: "2024-10-12 10:00 AM",
                timeRange: "10:00 AM - 11:00 AM",
                imageUrl: 'https://i.pravatar.cc/150?img=12',
                style: SessionCardStyle.white,
                name: "أحمد منصور",
                handle: "@fdtgsyhujkl",
                buttonText: "التفاصيل",
              );
            }, childCount: 5),
          ),

          SliverToBoxAdapter(child: SizedBox(height: context.height * 0.1)),
        ],
      ),
    );
  }
}
