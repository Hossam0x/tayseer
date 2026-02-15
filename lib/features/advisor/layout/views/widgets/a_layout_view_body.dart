import 'package:tayseer/features/advisor/chat/presentation/view/chat_view.dart';
import 'package:tayseer/features/shared/event/view/event_view.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/a_nav_bar.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/custom_feb_menu.dart'; // تأكد من الاستدعاء
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/features/advisor/profille/views/profile_view.dart';
import 'package:tayseer/features/user/my_space/presentation/view/my_space_view.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/user_type.dart';

class ALayOutViewBody extends StatelessWidget {
  const ALayOutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LayoutCubit>();

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final pages = _getPages(state.userType, cubit);

        return Scaffold(
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              IndexedStack(index: state.currentIndex, children: pages),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: state.isNavVisible ? Offset.zero : const Offset(0, 1),
                  child: ANavBar(),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: state.isNavVisible
                    ? MediaQuery.of(context).padding.bottom + 15.h
                    : -200.h,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 300),
                    scale: state.isNavVisible ? 1.0 : 0.0,
                    curve: Curves.easeOutBack,
                    child: CustomFabMenu(
                      isVisible: state.isNavVisible && state.currentIndex == 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getPages(UserTypeEnum userType, LayoutCubit cubit) {
    switch (userType) {
      case UserTypeEnum.asConsultant:
        return [
          HomeView(onScroll: cubit.onScroll),
          const ChatView(),
          EventView(),
          ProfileView(),
        ];

      case UserTypeEnum.user:
        return [
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
      case UserTypeEnum.guest:
        return [
          HomeView(onScroll: cubit.onScroll),
          GuestLockWidget(
            message: 'فرص التوافق تبدأ بعد التسجيل',
            description:
                'أنشئ حسابك عشان تقدر تتعرف على أشخاص مناسبين ليك بطريقة آمنة ومُنظمة.',
          ),
          MySpaceView(),
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
