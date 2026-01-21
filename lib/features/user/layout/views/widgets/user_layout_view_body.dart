import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';

import 'package:tayseer/features/user/layout/views/widgets/user_nav_bar.dart';
import 'package:tayseer/features/user/marriage/view/marriage_view.dart';
import 'package:tayseer/my_import.dart';

class UserLayOutViewBody extends StatelessWidget {
  const UserLayOutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LayoutCubit>();

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final pages = _getPages(cubit);

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
                  child: const UserNavBar(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getPages(LayoutCubit cubit) {
    switch (selectedUserType) {
      case UserTypeEnum.user:
        return [
          HomeView(onScroll: cubit.onScroll),
          MarriageView(),
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
