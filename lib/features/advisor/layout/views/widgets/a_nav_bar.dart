import 'package:tayseer/features/advisor/layout/views/widgets/nav_bar_config.dart';
import 'package:tayseer/my_import.dart';
// لاحظ: شيلنا استدعاء CustomFabMenu من هنا لأنه بقى برا

class ANavBar extends StatelessWidget {
  const ANavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final cubit = context.read<LayoutCubit>();
        final navItems = NavBarConfig.getNavItems(state.userType);

        // تقسيم العناصر يمين وشمال
        final int midPoint = (navItems.length / 2).floor();
        final leftItems = navItems.sublist(0, midPoint);
        final rightItems = navItems.sublist(midPoint);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(leftItems.length, (index) {
                          return _NavItem(
                            icon: leftItems[index].icon,
                            activeIcon: leftItems[index].activeIcon,
                            label: context.tr(leftItems[index].labelKey),
                            isActive: state.currentIndex == index,
                            onTap: () => cubit.changeIndex(index),
                          );
                        }),
                      ),
                    ),

                    SizedBox(width: 80.w),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(rightItems.length, (index) {
                          final realIndex = index + midPoint;
                          return _NavItem(
                            icon: rightItems[index].icon,
                            activeIcon: rightItems[index].activeIcon,
                            label: context.tr(rightItems[index].labelKey),
                            isActive: state.currentIndex == realIndex,
                            onTap: () => cubit.changeIndex(realIndex),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// كلاس _NavItem زي ما هو بدون تغيير
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

    if (widget.isActive) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
        color: Colors.transparent, // منطقة ضغط أوسع
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
