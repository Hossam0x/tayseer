// features/advisor/layout/views/widgets/a_layout_view_body.dart

import 'package:tayseer/features/advisor/chat/presentation/view/chat_view.dart';
import 'package:tayseer/features/advisor/event/view/event_view.dart';
import 'package:tayseer/features/advisor/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/a_nav_bar.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/custom_feb_menu.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/user_type.dart';

class ALayOutViewBody extends StatelessWidget {
  const ALayOutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ALayoutCubit>();

    return BlocBuilder<ALayoutCubit, ALayoutState>(
      builder: (context, state) {
        final pages = _getPages(state.userType, cubit);

        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(index: state.currentIndex, children: pages),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: state.isNavVisible ? Offset.zero : const Offset(0, 1),
                  child: const ANavBar(),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: 20,

                bottom: state.isNavVisible && state.currentIndex == 0
                    ? 90
                    : -400,

                child: SafeArea(child: const CustomFabMenu()),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getPages(UserTypeEnum userType, ALayoutCubit cubit) {
    switch (userType) {
      case UserTypeEnum.asConsultant:
        return [
          HomeView(onScroll: cubit.onScroll),
          const ChatView(),
          EventView(),
          Container(
            color: Colors.white,
            child: const Center(child: Text('Profile')),
          ),
        ];

      case UserTypeEnum.user:
      case UserTypeEnum.guest:
        return [
          HomeView(onScroll: cubit.onScroll),
          GuestLockWidget(
            message: 'فرص التوافق تبدأ بعد التسجيل',
            description:
                'أنشئ حسابك عشان تقدر تتعرف على أشخاص مناسبين ليك بطريقة آمنة ومُنظمة.',
          ),
          GuestLockWidget(
            message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
            description:
                'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
          ),
          GuestLockWidget(
            message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
            description:
                'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
          ),
          GuestLockWidget(
            message: 'إنشاء ملفك الشخصي أولًا',
            description:
                'التسجيل بيسمح لك بإنشاء ملفك وعرض الملفات المناسبة لك.',
          ),
        ];
    }
  }
}
