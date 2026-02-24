import 'package:flutter/services.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/shared/event/view/event_view.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_body.dart';
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
        final pages = _getPages(context, cubit, state);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBackButton(context, cubit, state);
          },
          child: Scaffold(
            body: Stack(
              children: [
                IndexedStack(index: state.currentIndex, children: pages),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    offset: state.isNavVisible
                        ? Offset.zero
                        : const Offset(0, 1),
                    child: UserNavBar(
                      onTabReselect: (index) {
                        // ✅ لو ضغط على السوشيال وهو واقف فيها، يعمل scroll to top
                        if (index == 0 && state.currentIndex == 0) {
                          cubit.scrollToTop();
                          cubit.setNavVisibility(true);
                        }
                        // ✅ Interactions في index 3
                        else if (index == 3 && state.currentIndex == 3) {
                          _interactionsKey.currentState?.handleTabReselect();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ من نسخة صاحبك - التعامل مع زرار الرجوع
  void _handleBackButton(
    BuildContext context,
    LayoutCubit cubit,
    LayoutState state,
  ) {
    if (state.currentIndex != 0) {
      // لو مش في السوشيال (Home)، يرجع للسوشيال
      cubit.changeIndex(0);
      cubit.setNavVisibility(true);
    } else if (!state.isHomeAtTop) {
      // لو في السوشيال بس عامل سكرول لتحت، يطلع فوق
      cubit.scrollToTop();
      cubit.setNavVisibility(true);
    } else {
      // لو في السوشيال وفوق خلاص، يظهر ديالوج تأكيد الخروج
      CustomshowDialogWithImage(
        context,
        title: context.tr('exit_app_title'),
        supTitle: context.tr('exit_app_message'),
        icon: Icons.exit_to_app_rounded,
        iconColor: Colors.red,
        iconBackgroundColor: Colors.red.withOpacity(0.1),
        bottonText: context.tr('cancel'),
        onPressed: () {},
        showCancelButton: true,
        cancelText: context.tr('exit_app'),
        onCancel: () => SystemNavigator.pop(),
      );
    }
  }

  List<Widget> _getPages(BuildContext context, LayoutCubit cubit,LayoutState state) {
    switch (selectedUserType) {
      case UserTypeEnum.user:
        return [
          HomeView(onScroll: cubit.onScroll),
          state.isMarriageVisible ? MarriageView() : const SizedBox.shrink(),
          MySpaceView(),
          EventView(),
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
              CachNetwork.removeData(key: ktoken);
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
              CachNetwork.removeData(key: ktoken);
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
              CachNetwork.removeData(key: ktoken);
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
              CachNetwork.removeData(key: ktoken);
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
