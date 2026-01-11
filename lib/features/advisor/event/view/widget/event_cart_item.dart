import 'dart:ui';
import 'package:tayseer/features/advisor/event/view/widget/app_media.dart';
import 'package:tayseer/my_import.dart';
import 'package:flutter/services.dart';

/// Model for long press actions
class EventCardAction {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const EventCardAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });
}

class EventCardItem extends StatefulWidget {
  final String imageUrl;
  final String sessionTitle;
  final String location;
  final String advisorName;
  final String dateTime;
  final String price;
  final String oldPrice;

  final bool isFeatured;
  final List<String> attendeesImages;
  final int attendeesCount;
  final VoidCallback? onTap;

  // More options (3 dots)
  final bool showMoreOptions;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final List<PopupMenuEntry<String>>? customMenuItems;
  final void Function(String)? onMenuItemSelected;

  // Long press
  final bool enableLongPress;
  final List<EventCardAction>? longPressActions;

  // ✅ Animation options
  final bool enableTapAnimation;

  const EventCardItem({
    super.key,
    required this.imageUrl,
    required this.sessionTitle,
    required this.location,
    required this.advisorName,
    required this.dateTime,
    required this.price,
    required this.oldPrice,
    this.isFeatured = false,
    this.attendeesImages = const [],
    this.attendeesCount = 0,
    this.onTap,
    this.showMoreOptions = false,
    this.onDelete,
    this.onEdit,
    this.customMenuItems,
    this.onMenuItemSelected,
    this.enableLongPress = false,
    this.longPressActions,
    this.enableTapAnimation = true, // ✅ مفعل افتراضياً
  });

  @override
  State<EventCardItem> createState() => _EventCardItemState();
}

class _EventCardItemState extends State<EventCardItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _elevationAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enableTapAnimation) return;
    setState(() => _isPressed = true);
    _animationController.forward();
    // Haptic feedback خفيف
    // HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enableTapAnimation) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    if (!widget.enableTapAnimation) return;
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    if (!widget.enableLongPress) return;
    HapticFeedback.mediumImpact();
    _showLongPressOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPressStart: widget.enableLongPress ? _onLongPressStart : null,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      0.1 + (_elevationAnimation.value * 0.02),
                    ),
                    blurRadius: 8 + _elevationAnimation.value,
                    offset: Offset(0, 4 + _elevationAnimation.value / 2),
                    spreadRadius: _elevationAnimation.value / 4,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: _buildCard(context),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      height: context.responsiveHeight(280),
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            /// 1. صورة الخلفية مع تأثير خفيف عند الضغط
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(_isPressed ? 0.1 : 0.0),
                      BlendMode.darken,
                    ),
                    child: child,
                  );
                },
                child: AppMedia(widget.imageUrl, fit: BoxFit.cover),
              ),
            ),

            /// 2. More Options Button (Three dots)
            if (widget.showMoreOptions)
              Positioned(
                top: 12,
                left: 12,
                child: _MoreOptionsButton(
                  onDelete: widget.onDelete,
                  onEdit: widget.onEdit,
                  customMenuItems: widget.customMenuItems,
                  onMenuItemSelected: widget.onMenuItemSelected,
                ),
              ),

            /// 3. Badge مميز
            if (widget.isFeatured)
              Positioned(
                top: 15,
                right: 15,
                child: _AnimatedBadge(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFDC830), Color(0xFFF37335)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      context.tr('featured'),
                      style: Styles.textStyle14.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

            /// 4. صور الحضور
            if (widget.attendeesImages.isNotEmpty)
              Positioned(
                top: 15,
                left: widget.showMoreOptions ? 55 : 15,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.attendeesCount}',
                      style: Styles.textStyle16.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            blurRadius: 4,
                            color: Colors.black45,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 35,
                      width:
                          35.0 +
                          ((widget.attendeesImages.take(3).length - 1) * 20),
                      child: Stack(
                        children: List.generate(
                          widget.attendeesImages.take(3).length,
                          (index) {
                            return Positioned(
                              left: index * 20.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: AppImage(
                                    widget.attendeesImages[index],
                                    width: 35,
                                    height: 35,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ).reversed.toList(),
                      ),
                    ),
                  ],
                ),
              ),

            /// 5. البطاقة السفلية
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF5E3F68).withOpacity(0.85),
                          const Color(0xFF2D1B36).withOpacity(0.70),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.sessionTitle,
                                style: Styles.textStyle14.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              _buildIconText(
                                Icons.location_on_outlined,
                                widget.location,
                              ),
                              _buildIconText(
                                Icons.person_outline,
                                widget.advisorName,
                              ),
                              _buildIconText(
                                Icons.calendar_month_outlined,
                                widget.dateTime,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.15),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.tr('session_price'),
                                style: Styles.textStyle10.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.price,
                                textDirection: TextDirection.ltr,
                                style: Styles.textStyle18Bold.copyWith(
                                  color: const Color(0xFFEFA6A8),
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${context.tr('instead_of')} ${widget.oldPrice}',
                                style: Styles.textStyle10.copyWith(
                                  color: Colors.white70,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.white70,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLongPressOverlay(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _LongPressOverlay(
            card: _buildCard(context),
            actions: widget.longPressActions ?? [],
            animation: animation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: Styles.textStyle10.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Animated Badge with shimmer effect
class _AnimatedBadge extends StatefulWidget {
  final Widget child;

  const _AnimatedBadge({required this.child});

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [Colors.white, Colors.white24, Colors.white],
              stops: [
                _shimmerAnimation.value - 0.3,
                _shimmerAnimation.value,
                _shimmerAnimation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// More Options Button Widget (3 dots) with animation
class _MoreOptionsButton extends StatefulWidget {
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final List<PopupMenuEntry<String>>? customMenuItems;
  final void Function(String)? onMenuItemSelected;

  const _MoreOptionsButton({
    this.onDelete,
    this.onEdit,
    this.customMenuItems,
    this.onMenuItemSelected,
  });

  @override
  State<_MoreOptionsButton> createState() => _MoreOptionsButtonState();
}

class _MoreOptionsButtonState extends State<_MoreOptionsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(25),
      ),
      child: PopupMenuButton<String>(
        icon: RotationTransition(
          turns: _rotationAnimation,
          child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 5, minHeight: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        onOpened: () {
          // HapticFeedback.selectionClick();
          _controller.forward();
        },
        onCanceled: () => _controller.reverse(),
        onSelected: (value) {
          _controller.reverse();
          if (widget.onMenuItemSelected != null) {
            widget.onMenuItemSelected!(value);
          } else {
            switch (value) {
              // case 'edit':
              //   widget.onEdit?.call();
              //   break;
              case 'delete':
                widget.onDelete?.call();
                break;
            }
          }
        },
        itemBuilder: (context) {
          if (widget.customMenuItems != null) {
            return widget.customMenuItems!;
          }
          return [
            if (widget.onEdit != null)
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(context.tr('edit')),
                  ],
                ),
              ),
            if (widget.onDelete != null)
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.tr('delete'),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
          ];
        },
      ),
    );
  }
}

/// Long Press Overlay Widget with enhanced animations
class _LongPressOverlay extends StatelessWidget {
  final Widget card;
  final List<EventCardAction> actions;
  final Animation<double> animation;

  const _LongPressOverlay({
    required this.card,
    required this.actions,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Container(
                color: Colors.black.withOpacity(0.5 * animation.value),
                child: child,
              );
            },
            child: SafeArea(
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: const Interval(
                            0.3,
                            1.0,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Card with bounce animation
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.elasticOut,
                      ),
                    ),
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Hero(
                          tag: 'event_card_hero',
                          child: Material(
                            color: Colors.transparent,
                            child: card,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Actions with staggered animation
                  if (actions.isNotEmpty)
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: const Interval(
                                0.2,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: const Interval(0.3, 1.0),
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: actions.asMap().entries.map((entry) {
                              final index = entry.key;
                              final action = entry.value;

                              // Staggered animation for each item
                              final delay = index * 0.1;
                              final itemAnimation = CurvedAnimation(
                                parent: animation,
                                curve: Interval(
                                  0.3 + delay,
                                  0.6 + delay,
                                  curve: Curves.easeOutCubic,
                                ),
                              );

                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.2, 0),
                                  end: Offset.zero,
                                ).animate(itemAnimation),
                                child: FadeTransition(
                                  opacity: itemAnimation,
                                  child: Column(
                                    children: [
                                      _ActionListTile(
                                        action: action,
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          Navigator.of(context).pop();
                                          action.onTap();
                                        },
                                      ),
                                      if (index < actions.length - 1)
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Action List Tile with press animation
class _ActionListTile extends StatefulWidget {
  final EventCardAction action;
  final VoidCallback onTap;

  const _ActionListTile({required this.action, required this.onTap});

  @override
  State<_ActionListTile> createState() => _ActionListTileState();
}

class _ActionListTileState extends State<_ActionListTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _isPressed ? Colors.grey.withOpacity(0.1) : Colors.transparent,
        child: ListTile(
          leading: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
            child: Icon(widget.action.icon, color: widget.action.iconColor),
          ),
          title: Text(
            widget.action.title,
            style: TextStyle(
              color: widget.action.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isPressed ? 0.05 : 0,
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // الألوان المستخدمة في الشيمار (رمادي فاتح وغامق)
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Container(
      height: context.responsiveHeight(280),
      width: context.width,
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor, // لون الخلفية عشان الظل يظهر
        borderRadius: BorderRadius.circular(20),
        // ✅ 1. نفس الظل الموجود في الكلاس الأصلي مع التدوير
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // لون ظل أخف قليلاً للشيمار
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              /// 1. خلفية الكارت (مكان الصورة)
              Container(
                color: baseColor,
                width: double.infinity,
                height: double.infinity,
              ),

              /// 2. مكان أيقونة القائمة (دائرة صغيرة)
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              /// 3. محاكاة الكونتينر الزجاجي العائم
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // لون شفاف قليلاً لتمييزه عن الخلفية
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      /// محاكاة الجزء الأيمن (التفاصيل)
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // عنوان الجلسة (مستطيل عريض)
                            _buildShimmerLine(width: 120, height: 14),
                            const SizedBox(height: 10),
                            // الموقع (مستطيل أصغر)
                            _buildShimmerLine(width: 90, height: 10),
                            const SizedBox(height: 6),
                            // المستشار
                            _buildShimmerLine(width: 80, height: 10),
                            const SizedBox(height: 6),
                            // التاريخ
                            _buildShimmerLine(width: 100, height: 10),
                          ],
                        ),
                      ),

                      // خط فاصل
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                      ),

                      /// محاكاة الجزء الأيسر (السعر)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // كلمة سعر الجلسة
                            _buildShimmerLine(width: 40, height: 8),
                            const SizedBox(height: 6),
                            // السعر (مستطيل كبير)
                            _buildShimmerLine(width: 60, height: 16),
                            const SizedBox(height: 6),
                            // السعر القديم
                            _buildShimmerLine(width: 40, height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
