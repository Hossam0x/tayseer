// features/advisor/layout/views/widgets/a_nav_bar.dart
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/advisor/layout/views/widgets/nav_bar_config.dart';
import 'package:tayseer/my_import.dart';

class UserNavBar extends StatelessWidget {
  const UserNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LayoutCubit, LayoutState>(
      builder: (context, state) {
        final cubit = context.read<LayoutCubit>();
        final navItems = NavBarConfig.getNavItems(
          selectedUserType ?? UserTypeEnum.user,
        );

        return Container(
          padding: EdgeInsets.only(top: context.responsiveHeight(16)),
          color: AppColors.kWhiteColor,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                navItems.length,
                (index) => _NavItem(
                  icon: navItems[index].icon,
                  activeIcon: navItems[index].activeIcon,
                  label: context.tr(navItems[index].labelKey),
                  isActive: state.currentIndex == index,
                  onTap: () => cubit.changeIndex(index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: widget.isActive ? 1.0 : _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(
                    widget.isActive ? widget.activeIcon : widget.icon,
                    width: context.responsiveWidth(widget.isActive ? 26 : 24),
                    height: context.responsiveHeight(widget.isActive ? 26 : 24),
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
    );
  }
}
