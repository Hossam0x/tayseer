import 'package:flutter/services.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/offline_banner.dart';
import 'package:tayseer/features/shared/reels/views/reels_nav_view.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/guest_lock_widget.dart';
import 'package:tayseer/features/user/consultation_filtter/presentation/view/consultation_standalone_page.dart';
import 'package:tayseer/features/user/layout/view/widgets/user_nav_bar.dart';
import 'package:tayseer/features/user/marriage/view/marriage_view.dart';
import 'package:tayseer/features/user/marriage/view/widget/marriage_body.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_state_cubit.dart';
import 'package:tayseer/features/user/my_space/presentation/view/my_space_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_profile_view.dart';
import 'package:tayseer/my_import.dart';

class UserLayOutViewBody extends StatefulWidget {
  const UserLayOutViewBody({super.key});

  @override
  State<UserLayOutViewBody> createState() => _UserLayOutViewBodyState();
}

class _UserLayOutViewBodyState extends State<UserLayOutViewBody> {
  // ✅ إضافة Key للـ MarriageBody للتحكم في الـ Scroll
  final GlobalKey<MarriageBodyState> _marriageKey =
      GlobalKey<MarriageBodyState>();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LayoutCubit>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackButton(context, cubit, cubit.state);
      },
      child: BlocConsumer<LayoutCubit, LayoutState>(
        listenWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
        listener: (context, state) {
          // وقف كل الفيديوهات لما تتغير الـ tab
          VideoManager.instance.stopAll();
        },
        builder: (context, state) {
          final pages = _getPages(context, cubit, state);

          return Scaffold(
            body: Column(
              children: [
                const OfflineBanner(),
                Expanded(
                  child: Stack(
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
                              // ✅ Home tab - scroll to top
                              if (index == 0 && state.currentIndex == 0) {
                                cubit.scrollToTop();
                                cubit.setNavVisibility(true);
                              }
                              // ✅ Marriage tab - scroll to top
                              else if (index == 1 && state.currentIndex == 1) {
                                _marriageKey.currentState?.scrollToTop();
                                cubit.setNavVisibility(true);
                              }
                              // ✅ Reels in index 3
                              else if (index == 3) {
                                cubit.setNavVisibility(false);
                              }
                              // ✅ Profile in index 4
                              else if (index == 4 && state.currentIndex == 4) {
                                cubit.scrollToTop();
                                cubit.setNavVisibility(true);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleBackButton(
    BuildContext context,
    LayoutCubit cubit,
    LayoutState state,
  ) {
    if (state.currentIndex != 0) {
      cubit.changeIndex(0);
      cubit.setNavVisibility(true);
    } else if (!state.isHomeAtTop) {
      cubit.scrollToTop();
      cubit.setNavVisibility(true);
    } else {
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

  List<Widget> _getPages(
    BuildContext context,
    LayoutCubit cubit,
    LayoutState state,
  ) {
    switch (selectedUserType) {
      case UserTypeEnum.user:
        return [
          HomeView(onScroll: cubit.onScroll),
          state.isMarriageVisible
              ? MarriageView(key: _marriageKey, onScroll: cubit.onScroll)
              : const _ConsultationTab(),

          MySpaceView(),
          const ReelsNavView(tabIndex: 3),
          const UserProfileView(),
        ];

      case UserTypeEnum.guest:
        return [
          HomeView(onScroll: cubit.onScroll),
          GuestLockWidget(
            onTap: () {
              CachNetwork.clearGuestAndProfileCache();
              if (getIt.isRegistered<HomeCubit>()) {
                getIt.resetLazySingleton<HomeCubit>();
              }
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
              CachNetwork.clearGuestAndProfileCache();
              if (getIt.isRegistered<HomeCubit>()) {
                getIt.resetLazySingleton<HomeCubit>();
              }
              context.pushNamedAndRemoveUntil(
                AppRouter.kRegisrationView,
                predicate: (_) => false,
              );
            },
          ),
          const ReelsNavView(tabIndex: 3),
          GuestLockWidget(
            message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
            description:
                'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
            onTap: () {
              CachNetwork.clearGuestAndProfileCache();
              if (getIt.isRegistered<HomeCubit>()) {
                getIt.resetLazySingleton<HomeCubit>();
              }
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

class _ConsultationTab extends StatelessWidget {
  const _ConsultationTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MySpaceCubit(getIt<MySpaceRepo>()),
      child: const ConsultationStandalonePage(),
    );
  }
}
