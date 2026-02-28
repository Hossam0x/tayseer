import 'package:flutter/services.dart';
import 'package:tayseer/features/advisor/chat/presentation/view/chat_view.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/a_nav_bar.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/add_post_button.dart';
import 'package:tayseer/features/advisor/profille/views/profile_view.dart';
import 'package:tayseer/features/shared/event/view/event_view.dart';
import 'package:tayseer/features/shared/home/views/home_view.dart';
import 'package:tayseer/my_import.dart';

class ALayOutViewBody extends StatelessWidget {
  const ALayOutViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LayoutCubit>();
    final pages = [
      HomeView(onScroll: cubit.onScroll),
      const ChatView(),
      EventView(),
      ProfileView(),
    ];
    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBackButton(context, cubit, state);
          },
          child: Scaffold(
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
