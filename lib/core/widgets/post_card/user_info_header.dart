// lib/core/widgets/user_info_header.dart
import 'package:flutter/services.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/utils/navigation_guard.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
import 'package:tayseer/my_import.dart';
// import your styles and assets...

class UserInfoHeader extends StatelessWidget {
  final String avatar;
  final String name;
  final bool isVerified;
  final Widget? subtitle; // خليناه ويدجت عشان المرونة (نص، تاريخ، ايقونات)
  final VoidCallback? onMoreTap;
  final String advisorId;
  final bool isFromProfile;
  final String userType;
  final bool isMine;
  final bool isFollowing;
  final VoidCallback? onFollowTap;

  const UserInfoHeader({
    super.key,
    required this.avatar,
    required this.name,
    required this.advisorId,
    this.isVerified = false,
    this.subtitle,
    this.onMoreTap,
    required this.isFromProfile,
    required this.userType,
    required this.isMine,
    this.isFollowing = true,
    this.onFollowTap,
  });

  void _navigateToUserProfile(BuildContext context) {
    if (!NavigationGuard.canNavigate()) return;
    if (userType.toLowerCase() == 'advisor') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UserAdvisorProfileView(advisorId: advisorId, advisorName: name),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserPublicProfileView(userId: advisorId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تجميع الصورة والاسم في GestureDetector واحد
        Expanded(
          child: GestureDetector(
            onTap: () => (isFromProfile && isMine)
                ? null
                : _navigateToUserProfile(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: AppImage(avatar, fit: BoxFit.cover, isAvatar: true),
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: Styles.textStyle16SemiBold.copyWith(
                                color: HexColor("#19295C"),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            Gap(4.w),
                            Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16.sp,
                            ),
                          ],
                          // ✅ Follow button — shown only when not mine
                          if (!isMine && onFollowTap != null) ...[
                            Gap(8.w),
                            _FollowButton(
                              initiallyFollowing: isFollowing,
                              onTap: onFollowTap!,
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[Gap(2.h), subtitle!],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap(8.w),
        if (onMoreTap != null)
          CustomClick(
            onTap: onMoreTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_horiz,
                color: AppColors.kGreyB3,
                size: 26.sp,
              ),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 🔔 Follow Button with animation
// ══════════════════════════════════════════════════════════════════════════════

class _FollowButton extends StatefulWidget {
  final bool initiallyFollowing;
  final VoidCallback onTap;

  const _FollowButton({required this.initiallyFollowing, required this.onTap});

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late bool _isFollowing;
  bool _hasBeenTapped = false; // تتبع إذا تم الضغط محلياً

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.initiallyFollowing;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // Play follow/unfollow sound effect
    AudioService.instance.playFollowSound(isFollowing: !_isFollowing);

    // Heavy vibration on tap
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.heavyImpact();

    // Scale-down then back animation
    await _controller.forward();
    await _controller.reverse();

    // Toggle local state
    setState(() {
      _isFollowing = !_isFollowing;
      _hasBeenTapped = true;
    });

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان متابع من البداية ولم يتم الضغط محلياً، لا تظهر شيء
    if (widget.initiallyFollowing && !_hasBeenTapped) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: _isFollowing
              ? Text(
                  key: const ValueKey('following'),
                  context.tr('following'),
                  style: Styles.textStyle12SemiBold.copyWith(
                    color: AppColors.kGreyB3,
                  ),
                )
              : Text(
                  key: const ValueKey('follow'),
                  context.tr('follow'),
                  style: Styles.textStyle12SemiBold.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
        ),
      ),
    );
  }
}
