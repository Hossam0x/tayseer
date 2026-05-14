import 'package:flutter/services.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/services/secure_window_service.dart';
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
import 'package:tayseer/main.dart';
import 'package:tayseer/my_import.dart';

class UserLayOutViewBody extends StatefulWidget {
  const UserLayOutViewBody({super.key});

  @override
  State<UserLayOutViewBody> createState() => _UserLayOutViewBodyState();
}

class _UserLayOutViewBodyState extends State<UserLayOutViewBody> {
  final GlobalKey<MarriageBodyState> _marriageKey =
      GlobalKey<MarriageBodyState>();

  // ✅ Cached pages — created once, reused forever
  late final LayoutCubit _cubit;

  // ✅ User pages (cached individually so marriage swap is cheap)
  late final Widget _homeView;
  late final Widget _marriageView;
  late final Widget _consultationTab;
  late final Widget _mySpaceView;
  late final Widget _reelsView;
  late final Widget _profileView;

  // ✅ Guest pages
  late final List<Widget> _guestPages;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<LayoutCubit>();

    // ✅ أعد حساب الـ marriage visibility بعد ما الـ layout يتبني
    // عشان تضمن إن الـ flag اتحفظ بعد الـ login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.refreshMarriageVisibility();
    });

    // User pages
    _homeView = HomeView(onScroll: _cubit.onScroll);
    _marriageView = MarriageView(key: _marriageKey, onScroll: _cubit.onScroll);
    _consultationTab = const _ConsultationTab();
    _mySpaceView = MySpaceView();
    _reelsView = const ReelsNavView(tabIndex: 3);
    _profileView = const UserProfileView();

    // Guest pages (static, created once)
    _guestPages = [
      _homeView,
      GuestLockWidget(
        onTap: () => _guestAction(context),
        message: 'فرص التوافق تبدأ بعد التسجيل',
        description:
            'أنشئ حسابك عشان تقدر تتعرف على أشخاص مناسبين ليك بطريقة آمنة ومُنظمة.',
      ),
      GuestLockWidget(
        message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
        description:
            'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
        onTap: () => _guestAction(context),
      ),
      const ReelsNavView(tabIndex: 3),
      GuestLockWidget(
        message: 'تواصل مباشر مع الاشخاص و مستشار علاقات ',
        description:
            'التسجيل يتيح لك مراسلة المستشارين وحجز جلسات خاصة تناسب حالتك.',
        onTap: () => _guestAction(context),
      ),
    ];

    // ✅ الـ layout جاهز — افتح أي pending deep link
    isMainLayoutReady = true;
    _consumePendingDeepLink();
  }

  void _consumePendingDeepLink() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (pendingDeepLinkPersonId != null) {
        final id = pendingDeepLinkPersonId!;
        pendingDeepLinkPersonId = null;
        navigatorKey.currentState?.pushNamed(
          AppRouter.kMarriageView,
          arguments: {'personId': id},
        );
      } else if (pendingDeepLinkAdvisorId != null) {
        final id = pendingDeepLinkAdvisorId!;
        pendingDeepLinkAdvisorId = null;
        navigatorKey.currentState?.pushNamed(
          AppRouter.kUserProfileView,
          arguments: {'advisorId': id},
        );
      } else if (pendingDeepLinkUserId != null) {
        final id = pendingDeepLinkUserId!;
        pendingDeepLinkUserId = null;
        navigatorKey.currentState?.pushNamed(
          AppRouter.kUserPublicProfileView,
          arguments: id,
        );
      } else if (pendingDeepLinkPostId != null) {
        final id = pendingDeepLinkPostId!;
        pendingDeepLinkPostId = null;
        navigatorKey.currentState?.pushNamed(
          AppRouter.kPostDetailsView,
          arguments: {'postID': id},
        );
      }
    });
  }

  @override
  void dispose() {
    isMainLayoutReady = false;
    super.dispose();
  }

  void _guestAction(BuildContext context) {
    CachNetwork.clearGuestAndProfileCache();
    if (getIt.isRegistered<HomeCubit>()) {
      getIt.resetLazySingleton<HomeCubit>();
    }
    context.pushNamedAndRemoveUntil(
      AppRouter.kRegisrationView,
      predicate: (_) => false,
    );
  }

  // ✅ Returns cached pages — only the marriage/consultation swap is dynamic
  List<Widget> _getPages(bool isMarriageVisible) {
    switch (selectedUserType) {
      case UserTypeEnum.user:
        return [
          _homeView,
          isMarriageVisible ? _marriageView : _consultationTab,
          _mySpaceView,
          _reelsView,
          _profileView,
        ];
      case UserTypeEnum.guest:
        return _guestPages;
      case UserTypeEnum.asConsultant:
        return [];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackButton(context, _cubit, _cubit.state);
      },
      child: BlocConsumer<LayoutCubit, LayoutState>(
        listenWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
        listener: (context, state) {
          // وقف كل الفيديوهات لما تتغير الـ tab (بدون dispose)
          VideoManager.instance.pauseAll();

          // ✅ فعّل FLAG_SECURE لما تدخل تاب الزواج (index 1)، وشيله لما تخرج
          if (state.currentIndex == 1) {
            SecureWindowService.enable();
          } else {
            SecureWindowService.disable();
          }

          // ✅ حدّث عداد الـ notifications لما يتغير الـ tab
          getIt<ChatSocketService>().requestChatNotificationNumbers();
        },
        // ✅ Only rebuild for visual changes — not scroll/trigger state
        buildWhen: (prev, curr) =>
            prev.currentIndex != curr.currentIndex ||
            prev.isNavVisible != curr.isNavVisible ||
            prev.isMarriageVisible != curr.isMarriageVisible,
        builder: (context, state) {
          final pages = _getPages(state.isMarriageVisible);

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
                                _cubit.scrollToTop();
                                _cubit.setNavVisibility(true);
                              }
                              // ✅ Marriage tab - scroll to top
                              else if (index == 1 && state.currentIndex == 1) {
                                _marriageKey.currentState?.scrollToTop();
                                _cubit.setNavVisibility(true);
                              }
                              // ✅ Reels in index 3
                              else if (index == 3) {
                                _cubit.setNavVisibility(false);
                              }
                              // ✅ Profile in index 4
                              else if (index == 4 && state.currentIndex == 4) {
                                _cubit.scrollToTop();
                                _cubit.setNavVisibility(true);
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
