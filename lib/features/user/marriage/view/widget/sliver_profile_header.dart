import 'dart:ui';
import 'dart:math' as math;
import 'package:tayseer/core/constant/marriage_constants.dart';
import 'package:tayseer/core/widgets/screenshot_protected_image.dart';
import 'package:tayseer/features/user/marriage/view/widget/animated_be_first_button.dart';
import 'package:tayseer/features/user/marriage/view/widget/image_viewer_gallery.dart';
import 'package:tayseer/my_import.dart';

class SliverProfileHeader extends StatelessWidget {
  // ---------- الكارت الحالي (الأمامي) ----------
  final List<String> images;
  final String name;
  final String age;
  final String location;
  final String? tagsjob;
  final String? educationLevel;
  final String? religiousCommitment;
  final String? nationality;
  final String? height;
  final Widget? toggleWidget;
  final bool showTitleBar;
  final String? reportId;
  final bool shouldBlur;
  final bool isVerified;

  // ---------- الكارت اللي بعده (الخلفي) ----------
  final List<String>? nextImages;
  final String? nextName;
  final String? nextAge;
  final String? nextLocation;
  final String? nextTagsjob;
  final String? nextEducationLevel;
  final String? nextReligiousCommitment;
  final String? nextNationality;
  final String? nextHeight;
  final bool? nextIsVerified;
  final String? city;
  final double? distanceKm;
  final double swipeDirection;
  final double swipeProgress;

  final VoidCallback? onFavoriteTap;
  final bool isFavorited;

  // ✅ widget مخصص يتعرض في الـ left بدل AnimatedBeFirstButton
  final Widget? leftWidget;

  // subscription type: free, gold, ultra
  final String? subscriptionType;
  final String? nextSubscriptionType;

  // badges
  final bool recentlyJoined;
  final bool activeToday;

  const SliverProfileHeader({
    super.key,
    required this.images,
    required this.name,
    required this.age,
    required this.location,
    this.tagsjob,
    this.educationLevel,
    this.religiousCommitment,
    this.nationality,
    this.height,
    this.toggleWidget,
    this.showTitleBar = true,
    this.reportId,
    this.shouldBlur = false,
    this.isVerified = false,
    this.nextImages,
    this.nextName,
    this.nextAge,
    this.nextLocation,
    this.nextTagsjob,
    this.nextEducationLevel,
    this.nextReligiousCommitment,
    this.nextNationality,
    this.nextHeight,
    this.nextIsVerified,
    this.swipeDirection = 0,
    this.swipeProgress = 0,
    this.onFavoriteTap,
    this.isFavorited = false,
    this.city,
    this.distanceKm,
    this.leftWidget,
    this.subscriptionType,
    this.nextSubscriptionType,
    this.recentlyJoined = false,
    this.activeToday = false,
  });

  bool get _isAnimating => swipeProgress > 0.01;

  @override
  Widget build(BuildContext context) {
    final String coverImage = images.isNotEmpty ? images.first : '';
    final bool hasNext = nextName != null;

    final double maxAngleRad = 30 * math.pi / 180;
    final double currentAngle = swipeDirection * swipeProgress * maxAngleRad;
    final double maxTranslateX = 250.w;
    final double currentTranslateX =
        swipeDirection * swipeProgress * maxTranslateX;

    // ✅ حساب الـ status bar height
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // ✅ الـ toolbar height الكلي = الارتفاع الأصلي + الـ status bar
    final double totalToolbarHeight = 72.h + statusBarHeight;
    final double toolbarHeight = showTitleBar
        ? totalToolbarHeight
        : statusBarHeight;

    return SliverAppBar(
      // ✅ الشاشة كاملة من أول لآخر
      expandedHeight: context.height * 0.85.h,
      // ✅ toolbarHeight يشمل الـ status bar
      toolbarHeight: toolbarHeight,
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: showTitleBar
          ? SizedBox(
              // ✅ ارتفاع الـ title يشمل الـ status bar
              height: totalToolbarHeight,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: statusBarHeight,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (toggleWidget != null) Center(child: toggleWidget!),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          context.pushNamed(AppRouter.kMarriageFilterView);
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black26,
                          child: AppImage(
                            AssetsData.kfilterIcon,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                    // ✅ leftWidget أو AnimatedBeFirstButton الافتراضي
                    Positioned(
                      left: 0,
                      child:
                          leftWidget ??
                          AnimatedBeFirstButton(
                            onTap: () {
                              context.pushNamed(AppRouter.kBoostAccountView);
                            },
                          ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: RepaintBoundary(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ========= الكارت الخلفي =========
              if (hasNext && _isAnimating)
                RepaintBoundary(
                  child: _BackProfileCard(
                    nextImages: nextImages,
                    nextName: nextName,
                    nextAge: nextAge,
                    nextLocation: nextLocation,
                    nextTagsjob: nextTagsjob,
                    nextEducationLevel: nextEducationLevel,
                    nextReligiousCommitment: nextReligiousCommitment,
                    nextNationality: nextNationality,
                    nextHeight: nextHeight,
                    nextIsVerified: nextIsVerified ?? false,
                    nextSubscriptionType: nextSubscriptionType,
                  ),
                ),

              // ========= الكارت الأمامي =========
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(currentTranslateX, 0.0)
                  ..rotateZ(currentAngle),
                child: RepaintBoundary(
                  child: _FrontProfileCard(
                    city: city,
                    distanceKm: distanceKm,
                    images: images,
                    coverImage: coverImage,
                    reportId: reportId,
                    name: name,
                    age: age,
                    location: location,
                    tagsjob: tagsjob,
                    educationLevel: educationLevel,
                    religiousCommitment: religiousCommitment,
                    nationality: nationality,
                    height: height,
                    swipeProgress: swipeProgress,
                    isAnimating: _isAnimating,
                    onFavoriteTap: onFavoriteTap,
                    isFavorited: isFavorited,
                    shouldBlur: shouldBlur,
                    isVerified: isVerified,
                    subscriptionType: subscriptionType,
                    recentlyJoined: recentlyJoined,
                    activeToday: activeToday,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FRONT CARD
// ═══════════════════════════════════════════════════════════════
class _FrontProfileCard extends StatelessWidget {
  final String? city;
  final double? distanceKm;
  final List<String> images;
  final String coverImage;
  final String? reportId;
  final String name;
  final String age;
  final String location;
  final String? tagsjob;
  final String? educationLevel;
  final String? religiousCommitment;
  final String? nationality;
  final String? height;
  final double swipeProgress;
  final bool isAnimating;
  final VoidCallback? onFavoriteTap;
  final bool isFavorited;
  final bool shouldBlur;
  final bool isVerified;
  final String? subscriptionType;
  final bool recentlyJoined;
  final bool activeToday;

  const _FrontProfileCard({
    required this.images,
    required this.coverImage,
    required this.reportId,
    required this.name,
    required this.age,
    required this.location,
    this.tagsjob,
    this.educationLevel,
    this.religiousCommitment,
    this.nationality,
    this.height,
    required this.swipeProgress,
    required this.isAnimating,
    this.onFavoriteTap,
    this.isFavorited = false,
    this.shouldBlur = false,
    this.isVerified = false,
    this.city,
    this.distanceKm,
    this.subscriptionType,
    this.recentlyJoined = false,
    this.activeToday = false,
  });

  bool get _hasImage => coverImage.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final double bottomRadius = 80 * swipeProgress;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ الصورة فقط داخل SecureImageWrapper — محمية من screenshot
        GestureDetector(
          onTap: () {
            if (images.isNotEmpty && !shouldBlur) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageViewerGallery(
                    images: images,
                    initialIndex: 0,
                    personId: reportId,
                  ),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(bottomRadius),
              bottomRight: Radius.circular(bottomRadius),
            ),
            child: !_hasImage
                ? _buildPlaceholder()
                : ScreenshotProtectedImage(
                    imageUrl: coverImage,
                    fit: BoxFit.cover,
                    isAnimating: isAnimating,
                    shouldBlur: shouldBlur,
                  ),
          ),
        ),

        // ✅ الـ gradient خارج الـ SecureImageWrapper — يظهر في screenshot
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(bottomRadius),
                bottomRight: Radius.circular(bottomRadius),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.65),
                    ],
                    stops: const [0.0, 0.45, 0.72, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),

        if (shouldBlur)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

        // ✅ المعلومات خارج الـ SecureImageWrapper — تظهر في screenshot
        Positioned(
          bottom: 0.h,
          right: 0.w,
          left: 0.w,
          child: _InfoCard(
            name: name,
            age: age,
            location: location,
            tagsjob: tagsjob,
            educationLevel: educationLevel,
            religiousCommitment: religiousCommitment,
            nationality: nationality,
            height: height,
            useBlur: !isAnimating && _hasImage,
            opacity: 0.18,
            onFavoriteTap: onFavoriteTap,
            isFavorited: isFavorited,
            isVerified: isVerified,
            city: city,
            distanceKm: distanceKm,
            subscriptionType: subscriptionType,
          ),
        ),

        // ✅ Badges: activeToday & recentlyJoined
        if (activeToday || recentlyJoined)
          Positioned(
            top: 150.h,
            right: 16.w,
            child: Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                if (activeToday)
                  _buildBadge(
                    icon: Icons.circle,
                    iconColor: const Color(0xFF4CAF50),
                    label: context.tr('active_today'),
                    bgColor: Colors.black.withOpacity(0.55),
                  ),
                if (activeToday && recentlyJoined) SizedBox(height: 8.h),
                if (recentlyJoined)
                  _buildBadge(
                    icon: Icons.person_add_rounded,
                    iconColor: const Color(0xFFE91E8C),
                    label: context.tr('recently_joined'),
                    bgColor: Colors.black.withOpacity(0.55),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color bgColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 10.r),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.kprimaryColor.withOpacity(0.15),
            AppColors.kprimaryColor.withOpacity(0.05),
            AppColors.kScaffoldColor,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.kprimaryColor.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.kprimaryColor.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 64.r,
                color: AppColors.kprimaryColor.withOpacity(0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BACK CARD
// ═══════════════════════════════════════════════════════════════
class _BackProfileCard extends StatelessWidget {
  final List<String>? nextImages;
  final String? nextName;
  final String? nextAge;
  final String? nextLocation;
  final String? nextTagsjob;
  final String? nextEducationLevel;
  final String? nextReligiousCommitment;
  final String? nextNationality;
  final String? nextHeight;
  final bool nextIsVerified;
  final String? nextSubscriptionType;

  const _BackProfileCard({
    this.nextImages,
    this.nextName,
    this.nextAge,
    this.nextLocation,
    this.nextTagsjob,
    this.nextEducationLevel,
    this.nextReligiousCommitment,
    this.nextNationality,
    this.nextHeight,
    this.nextIsVerified = false,
    this.nextSubscriptionType,
  });

  @override
  Widget build(BuildContext context) {
    final String backCover = (nextImages != null && nextImages!.isNotEmpty)
        ? nextImages!.first
        : '';
    final bool hasBackImage = backCover.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (!hasBackImage)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.kprimaryColor.withOpacity(0.1),
                  AppColors.kScaffoldColor,
                ],
              ),
            ),
          )
        else
          AppImage(backCover, fit: BoxFit.cover),

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 60.h,
          right: 16.w,
          left: 16.w,
          child: _InfoCard(
            name: nextName ?? '',
            age: nextAge ?? '',
            location: nextLocation ?? '',
            tagsjob: nextTagsjob,
            educationLevel: nextEducationLevel,
            religiousCommitment: nextReligiousCommitment,
            nationality: nextNationality,
            height: nextHeight,
            useBlur: false,
            opacity: 0.14,
            onFavoriteTap: null,
            isFavorited: false,
            isVerified: nextIsVerified,
            subscriptionType: nextSubscriptionType,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INFO CARD
// ═══════════════════════════════════════════════════════════════
class _InfoCard extends StatelessWidget {
  final String name;
  final String age;
  final String location;
  final String? tagsjob;
  final String? educationLevel;
  final String? religiousCommitment;
  final String? nationality;
  final String? height;
  final bool useBlur;
  final double opacity;
  final VoidCallback? onFavoriteTap;
  final bool isFavorited;
  final bool isVerified;
  final double? distanceKm;
  final String? city;
  final String? subscriptionType;

  const _InfoCard({
    required this.name,
    required this.age,
    required this.location,
    this.tagsjob,
    this.educationLevel,
    this.religiousCommitment,
    this.nationality,
    this.height,
    required this.useBlur,
    required this.opacity,
    this.onFavoriteTap,
    this.isFavorited = false,
    this.isVerified = false,
    this.distanceKm,
    this.city,
    this.subscriptionType,
  });

  @override
  Widget build(BuildContext context) {
    return _glassCard(
      borderRadius: 24,
      blur: useBlur ? 18 : 0,
      opacity: opacity,
      paddingAll: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          name.isNotEmpty
                              ? '${name[0].toUpperCase()}${name.substring(1)}'
                              : name,
                          style: Styles.textStyle32Bold.copyWith(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.7),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Gap(2.w),
                    if (age.isNotEmpty)
                      Text(
                        "$age",
                        style: Styles.textStyle28.copyWith(color: Colors.white),
                      ),
                    if (isVerified) ...[
                      Gap(8.w),
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                    ],
                  ],
                ),
              ),
              if (onFavoriteTap != null) ...[
                Gap(8.w),
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Container(
                      key: ValueKey(isFavorited),
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        color: isFavorited ? Colors.red : Colors.white,
                        size: 30.r,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(width: 12.w),
              _buildSubscriptionIcon(),
            ],
          ),
          Gap(5.h),
          Row(
            children: [
              if (location.isNotEmpty) ...[
                Text(
                  CountryFlagUtils.getFlag(location),
                  style: const TextStyle(fontSize: 16),
                ),
                Gap(5.w),
                Flexible(
                  child: Text(
                    city != null && city!.isNotEmpty
                        ? '$location، ( $city )'
                        : location,
                    style: Styles.textStyle16.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else if (city != null && city!.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    city!,
                    style: Styles.textStyle14.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              if (distanceKm != null) ...[
                Gap(8.w),
                Text(
                  context.tr(
                    'distance_away',
                    args: [distanceKm!.toStringAsFixed(0)],
                  ),
                  style: Styles.textStyle14.copyWith(color: Colors.white70),
                ),
              ],
            ],
          ),
          Gap(10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (tagsjob != null && tagsjob!.isNotEmpty) _buildTag(tagsjob!),
              if (educationLevel != null && educationLevel!.isNotEmpty)
                _buildTag(educationLevel!),
              if (religiousCommitment != null &&
                  religiousCommitment!.isNotEmpty)
                _buildTag(religiousCommitment!),
              if (nationality != null && nationality!.isNotEmpty)
                _buildTag(nationality!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionIcon() {
    switch (subscriptionType?.toLowerCase()) {
      case 'gold':
        return AppImage(AssetsData.goldIcon, width: 35.w);
      case 'ultra':
        return AppImage(AssetsData.eliteIcon, width: 35.w);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.black.withOpacity(opacity),
        border: Border.all(color: Colors.black.withOpacity(0.2), width: 1.2),
      ),
      child: Text(
        text,
        style: Styles.textStyle12.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _glassCard({
    required Widget child,
    double borderRadius = 20,
    double blur = 20,
    double opacity = 0.25,
    double paddingAll = 0.0,
  }) {
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(opacity),
          Colors.white.withOpacity(opacity / 2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
    );

    if (blur <= 0) {
      return ClipRRect(
        child: Container(
          padding: EdgeInsets.all(paddingAll),
          decoration: decoration,
          child: child,
        ),
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: EdgeInsets.all(paddingAll),
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}
