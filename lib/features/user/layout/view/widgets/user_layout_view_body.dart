import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/interactions/presentation/view/interactions_view.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart'; // ✅ إضافة هذا
import 'package:tayseer/features/user/layout/view/widgets/user_nav_bar.dart';
import 'package:tayseer/features/user/marriage/view/marriage_view.dart';
import 'package:tayseer/features/user/my_space/presentation/view/my_space_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_profile_view.dart';
import 'package:tayseer/my_import.dart';

class UserLayOutViewBody extends StatefulWidget {
  const UserLayOutViewBody({super.key});

  @override
  State<UserLayOutViewBody> createState() => _UserLayOutViewBodyState();
}

class _UserLayOutViewBodyState extends State<UserLayOutViewBody> {
 // ✅ Now using the public InteractionBodyState class
  final GlobalKey<InteractionBodyState> _interactionsKey = 
      GlobalKey<InteractionBodyState>();
      
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LayoutCubit>();

    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final pages = _getPages(context, cubit);

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
                  child: UserNavBar(
                    onTabReselect: (index) {
                      // ✅ التحقق من التاب المختار (Interactions في index 3)
                      if (index == 3 && state.currentIndex == 3) {
                        _interactionsKey.currentState?.handleTabReselect();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _getPages(BuildContext context, LayoutCubit cubit) {
    switch (selectedUserType) {
      case UserTypeEnum.user:
        return [
          HomeView(onScroll: cubit.onScroll),
          MarriageView(),
          MySpaceView(),
          // ✅ بدلاً من تمرير key لـ InteractionsView، نستخدم BlocProvider مباشرة
          BlocProvider(
            create: (context) => getIt<InteractionsCubit>(),
            child: InteractionBody(key: _interactionsKey), // ✅ تمرير الـ Key مباشرة
          ),
          const UserProfileView(),
        ];

      case UserTypeEnum.guest:
        return [
          HomeView(onScroll: cubit.onScroll),
          GuestLockWidget(
            onTap: () {
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
            message: 'فرص التوافق تبدأ بعد التسجيل',
            description:
                'أنشئ حسابك عشان تقدر تتعرف على أشخاص مناسبين ليك بطريقة آمنة ومُنظمة.',
          ),
          GuestLockWidget(
            message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
            description:
                'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
            onTap: () {
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
          ),
          GuestLockWidget(
            message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
            description:
                'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
            onTap: () {
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
          ),
        ];

      case UserTypeEnum.asConsultant:
        return [];
      default:
        return [];
    }
  }
}