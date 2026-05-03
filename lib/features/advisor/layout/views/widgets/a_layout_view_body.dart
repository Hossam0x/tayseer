import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/widgets/offline_banner.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/chat_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/a_nav_bar.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/add_post_button.dart';
import 'package:tayseer/features/advisor/profille/views/profile_view.dart';
import 'package:tayseer/features/shared/reels/views/reels_nav_view.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/main.dart';
import 'package:tayseer/my_import.dart';

class ALayOutViewBody extends StatefulWidget {
  const ALayOutViewBody({super.key});

  @override
  State<ALayOutViewBody> createState() => _ALayOutViewBodyState();
}

class _ALayOutViewBodyState extends State<ALayOutViewBody> {
  // ✅ Cached — created once, reused forever
  late final LayoutCubit _cubit;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<LayoutCubit>();
    _pages = [
      HomeView(onScroll: _cubit.onScroll),
      const ChatView(),
      const ReelsNavView(tabIndex: 2),
      ProfileView(),
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit, LayoutState>(
      listenWhen: (prev, curr) => prev.currentIndex != curr.currentIndex,
      listener: (context, state) {
        // وقف كل الفيديوهات لما تتغير الـ tab (بدون dispose)
        VideoManager.instance.pauseAll();
      },
      // ✅ Only rebuild for visual changes — not scroll/trigger state
      buildWhen: (prev, curr) =>
          prev.currentIndex != curr.currentIndex ||
          prev.isNavVisible != curr.isNavVisible,
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBackButton(context, _cubit, state);
          },
          child: Scaffold(
            body: Column(
              children: [
                const OfflineBanner(),
                Expanded(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      IndexedStack(index: state.currentIndex, children: _pages),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          offset: state.isNavVisible
                              ? Offset.zero
                              : const Offset(0, 1),
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
                            child: AddPostButton(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
