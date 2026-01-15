import 'package:tayseer/features/advisor/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/a_nav_bar.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/custom_feb_menu.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/features/user/layout/view_model/user_layout_cubit.dart';
import 'package:tayseer/features/user/layout/view_model/user_layout_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/user_type.dart';

class UserLayOutViewBody extends StatelessWidget {
  const UserLayOutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<UserLayoutCubit>();

    return BlocBuilder<UserLayoutCubit, UserLayoutState>(
      builder: (context, state) {
        final pages = _getPages(cubit);

        final bool isFabVisible = state.isNavVisible && state.currentIndex == 0;

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
                // استخدام المتغير لتحديد الموقع
                bottom: isFabVisible ? 90.h : -400.h,

                child: SafeArea(
                  // تمرير المتغير للويدجت ليقوم بإغلاق نفسه عند الاختفاء
                  child: CustomFabMenu(isVisible: isFabVisible),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getPages(UserLayoutCubit cubit) {
    switch (selectedUserType) {
      case UserTypeEnum.user:
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

      case UserTypeEnum.asConsultant:
        return [];
      default:
        return [];
    }
  }
}
