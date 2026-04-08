// features/advisor/layout/views/widgets/a_nav_bar.dart
import 'dart:math';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/nav_bar_config.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/nav_animation_service.dart';
import 'package:tayseer/my_import.dart';

class UserNavBar extends StatefulWidget {
  final Function(int)? onTabReselect;
  const UserNavBar({super.key, this.onTabReselect});

  @override
  State<UserNavBar> createState() => _UserNavBarState();
}

class _UserNavBarState extends State<UserNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _toggleController;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _fadeAnim;
  final GlobalKey _navItem1Key = GlobalKey();

  @override
  void initState() {
    super.initState();
    NavAnimationService.instance.navItem1Key = _navItem1Key;
    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.45,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.45,
          end: 0.75,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.75,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 35,
      ),
    ]).animate(_toggleController);

    _rotateAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _toggleController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _fadeAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
    ]).animate(_toggleController);
  }

  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LayoutCubit, LayoutState>(
      listenWhen: (prev, curr) =>
          prev.marriageToggleTrigger != curr.marriageToggleTrigger,
      listener: (context, state) {
        // ⭐ شغّل الـ bounce animation لما يوصل الأيكون الطاير
        Future.delayed(const Duration(milliseconds: 650), () {
          if (mounted) _toggleController.forward(from: 0);
        });
      },
      builder: (context, state) {
        final cubit = context.read<LayoutCubit>();
        final allNavItems = NavBarConfig.getNavItems(
          selectedUserType ?? UserTypeEnum.user,
        );

        final visibleNavItems = <({int originalIndex, dynamic item})>[];
        for (int i = 0; i < allNavItems.length; i++) {
          if (i == 1 && !state.isMarriageVisible) {
            visibleNavItems.add((
              originalIndex: i,
              item: NavBarItem(
                icon: AssetsData.consultationIcon,
                activeIcon: AssetsData.consultationActiveIcon,
                labelKey: 'consultation',
              ),
            ));
            continue;
          }
          visibleNavItems.add((originalIndex: i, item: allNavItems[i]));
        }

        return Container(
          padding: EdgeInsets.only(top: context.responsiveHeight(16)),
          color: AppColors.kWhiteColor,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(visibleNavItems.length, (visibleIndex) {
                final entry = visibleNavItems[visibleIndex];
                final originalIndex = entry.originalIndex;
                final navItem = entry.item;
                final isActive = state.currentIndex == originalIndex;

                // ⭐ index 1: يأخذ GlobalKey + toggle animation
                if (originalIndex == 1) {
                  return _AnimatedNavItem(
                    key: _navItem1Key, // ⭐ GlobalKey
                    icon: navItem.icon,
                    activeIcon: navItem.activeIcon,
                    label: context.tr(navItem.labelKey),
                    isActive: isActive,
                    scaleAnim: _scaleAnim,
                    rotateAnim: _rotateAnim,
                    fadeAnim: _fadeAnim,
                    toggleController: _toggleController,
                    onTap: () {
                      if (originalIndex == state.currentIndex) {
                        widget.onTabReselect?.call(originalIndex);
                      } else {
                        cubit.changeIndex(originalIndex);
                      }
                    },
                  );
                }

                return _NavItem(
                  icon: navItem.icon,
                  activeIcon: navItem.activeIcon,
                  label: context.tr(navItem.labelKey),
                  isActive: isActive,
                  onTap: () {
                    if (originalIndex == state.currentIndex) {
                      widget.onTabReselect?.call(originalIndex);
                    } else {
                      cubit.changeIndex(originalIndex);
                      if (originalIndex == 3) {
                        cubit.setNavVisibility(false);
                      } else {
                        cubit.setNavVisibility(true);
                      }
                    }
                  },
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// ⭐ Nav item خاص بـ index 1 مع toggle animation
// ──────────────────────────────────────────────────────────────
class _AnimatedNavItem extends StatefulWidget {
  final String icon;
  final String activeIcon;
  final String label;
  final bool isActive;
  final Animation<double> scaleAnim;
  final Animation<double> rotateAnim;
  final Animation<double> fadeAnim;
  final AnimationController toggleController;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.scaleAnim,
    required this.rotateAnim,
    required this.fadeAnim,
    required this.toggleController,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _activeController;
  late Animation<double> _activeScale;

  @override
  void initState() {
    super.initState();
    _activeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _activeScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _activeController, curve: Curves.easeOut),
    );
    if (widget.isActive) _activeController.forward();
  }

  @override
  void didUpdateWidget(_AnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive
          ? _activeController.forward()
          : _activeController.reverse();
    }
  }

  @override
  void dispose() {
    _activeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            widget.toggleController,
            _activeController,
          ]),
          builder: (context, child) {
            final isToggling = widget.toggleController.isAnimating;

            return Transform.scale(
              scale: isToggling ? widget.scaleAnim.value : _activeScale.value,
              child: Opacity(
                opacity: widget.isActive ? 1.0 : 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Gap(8.h),
                    Transform.rotate(
                      angle: widget.rotateAnim.value * 2 * pi,
                      child: Opacity(
                        opacity: isToggling ? widget.fadeAnim.value : 1.0,
                        child: AppImage(
                          widget.isActive ? widget.activeIcon : widget.icon,
                          width: context.responsiveWidth(
                            widget.isActive ? 26 : 24,
                          ),
                          height: context.responsiveHeight(
                            widget.isActive ? 26 : 24,
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Gap(context.responsiveHeight(6)),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: widget.isActive
                          ? Styles.textStyle14SemiBold
                          : Styles.textStyle12.copyWith(
                              color: AppColors.kTextGrey,
                            ),
                      child: widget.isActive
                          ? GradientText(
                              text: widget.label,
                              style: Styles.textStyle14,
                            )
                          : Text(
                              widget.label,
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.kTextGrey,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// الـ Nav item العادي (بدون تغيير)
// ──────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final String activeIcon;
  final String icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: widget.isActive ? 1.0 : _fadeAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Gap(8.h),
                    AppImage(
                      widget.isActive ? widget.activeIcon : widget.icon,
                      width: context.responsiveWidth(widget.isActive ? 26 : 24),
                      height: context.responsiveHeight(
                        widget.isActive ? 26 : 24,
                      ),
                      fit: BoxFit.contain,
                    ),
                    Gap(context.responsiveHeight(6)),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: widget.isActive
                          ? Styles.textStyle14SemiBold
                          : Styles.textStyle12.copyWith(
                              color: AppColors.kTextGrey,
                            ),
                      child: widget.isActive
                          ? GradientText(
                              text: widget.label,
                              style: Styles.textStyle14,
                            )
                          : Text(
                              widget.label,
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.kTextGrey,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
