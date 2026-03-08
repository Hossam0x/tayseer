//  // lib/features/user/marriage/view/widget/sliver_profile_header.dart

// import 'dart:ui';
// import 'package:tayseer/features/user/marriage/view/widget/animated_be_first_button.dart';
// import 'package:tayseer/features/user/marriage/view/widget/image_viewer_gallery.dart';
// import 'package:tayseer/my_import.dart';

// class SliverProfileHeader extends StatelessWidget {
//   final List<String> images;
//   final String name;
//   final String age;
//   final String location;
//   final String? tagsjob;
//   final String? educationLevel;
//   final String? religiousCommitment;
//   final String? nationality;
//   final String? height;
//   final String? transitionKey;
//   final Widget? toggleWidget;
//   final String? reportId;
//   const SliverProfileHeader({
//     super.key,
//     required this.images,
//     required this.name,
//     required this.age,
//     required this.location,
//     this.tagsjob,
//     this.educationLevel,
//     this.religiousCommitment,
//     this.nationality,
//     this.height,
//     this.transitionKey,
//     this.toggleWidget,
//     this.reportId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final String coverImage = images.isNotEmpty ? images.first : '';

//     return SliverAppBar(
//       expandedHeight: context.height * 0.85,
//       pinned: true, // ✅ CHANGED: الأب بار يفضل ثابت
//       floating: false,
//       snap: false,
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       automaticallyImplyLeading: false,
//       titleSpacing: 0,
//       title: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             // ✅ Toggle ثابت في النص
//             if (toggleWidget != null) Center(child: toggleWidget!),

//             // ✅ Filter button
//             Positioned(
//               right: 0,
//               child: GestureDetector(
//                 onTap: () {
//                   context.pushNamed(AppRouter.kMarriageFilterView);
//                 },
//                 child: CircleAvatar(
//                   backgroundColor: Colors.black26,
//                   child: AppImage(
//                     AssetsData.kfilterIcon,
//                     width: 20,
//                     height: 20,
//                   ),
//                 ),
//               ),
//             ),

//             // ✅ Boost button
//             Positioned(
//               left: 0,
//               child: AnimatedBeFirstButton(
//                 onTap: () {
//                   context.pushNamed(AppRouter.kBoostAccountView);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       flexibleSpace: FlexibleSpaceBar(
//         collapseMode: CollapseMode.pin,
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             GestureDetector(
//               onTap: () {
//                 if (images.isNotEmpty) {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ImageViewerGallery(
//                         images: images,
//                         initialIndex: 0,
//                         personId: reportId,
//                       ),
//                     ),
//                   );
//                 }
//               },
//               child: Hero(
//                 tag: coverImage,
//                 child: AppImage(coverImage, fit: BoxFit.cover),
//               ),
//             ),
//             Positioned(
//               bottom: 60.h,
//               right: 16.w,
//               left: 16.w,
//               child: glassCard(
//                 borderRadius: 24,
//                 blur: 18,
//                 opacity: 0.18,
//                 paddingAll: 16,
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 380),
//                   transitionBuilder: (child, animation) {
//                     final offsetAnimation =
//                         Tween<Offset>(
//                           begin: const Offset(0, 0.35),
//                           end: Offset.zero,
//                         ).animate(
//                           CurvedAnimation(
//                             parent: animation,
//                             curve: Curves.easeOutCubic,
//                           ),
//                         );
//                     return SlideTransition(
//                       position: offsetAnimation,
//                       child: FadeTransition(opacity: animation, child: child),
//                     );
//                   },
//                   child: Container(
//                     key: ValueKey(transitionKey ?? name),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Text(
//                               name,
//                               style: Styles.textStyle18Bold.copyWith(
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Gap(5.w),
//                             Text(
//                               "$age ${context.tr("age")}",
//                               style: Styles.textStyle14.copyWith(
//                                 color: Colors.white,
//                               ),
//                             ),
//                             Gap(8.w),
//                             const Icon(
//                               Icons.verified,
//                               color: Colors.blue,
//                               size: 20,
//                             ),
//                           ],
//                         ),
//                         Gap(5.h),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.flag,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                             Gap(5.w),
//                             Text(
//                               location,
//                               style: Styles.textStyle12.copyWith(
//                                 color: Colors.white70,
//                               ),
//                             ),
//                           ],
//                         ),
//                         Gap(10.h),
//                         Wrap(
//                           spacing: 8.w,
//                           runSpacing: 8.h,
//                           children: [
//                             if (tagsjob != null && tagsjob!.isNotEmpty)
//                               _buildTransparentTag(tagsjob!),
//                             if (educationLevel != null &&
//                                 educationLevel!.isNotEmpty)
//                               _buildTransparentTag(educationLevel!),
//                             if (religiousCommitment != null &&
//                                 religiousCommitment!.isNotEmpty)
//                               _buildTransparentTag(religiousCommitment!),
//                             if (nationality != null && nationality!.isNotEmpty)
//                               _buildTransparentTag(nationality!),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTransparentTag(String text) {
//     return glassCard(
//       borderRadius: 24,
//       blur: 18,
//       opacity: 0.18,
//       paddingAll: 6,
//       child: Text(
//         text,
//         style: Styles.textStyle10.copyWith(color: Colors.white),
//       ),
//     );
//   }

//   Widget glassCard({
//     required Widget child,
//     double borderRadius = 20,
//     double blur = 20,
//     double opacity = 0.25,
//     double paddingAll = 0.0,
//   }) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(borderRadius),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
//         child: Container(
//           padding: EdgeInsets.all(paddingAll),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(borderRadius),
//             gradient: LinearGradient(
//               colors: [
//                 Colors.white.withOpacity(opacity),
//                 Colors.white.withOpacity(opacity / 2),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             border: Border.all(
//               color: Colors.white.withOpacity(0.2),
//               width: 1.2,
//             ),
//           ),
//           child: child,
//         ),
//       ),
//     );
//   }
// }
// lib/features/user/marriage/view/widget/sliver_profile_header.dart

// sliver_profile_header.dart
import 'dart:ui';
import 'dart:math' as math;
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
  final String? reportId;

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

  ///  1  = يمين (قلب)
  /// -1  = شمال (X)
  final double swipeDirection;

  /// من 0 → 1 : تقدم الأنيميشن (0 مفيش حركة، 1 خارج الشاشة)
  final double swipeProgress;

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
    this.reportId,
    this.nextImages,
    this.nextName,
    this.nextAge,
    this.nextLocation,
    this.nextTagsjob,
    this.nextEducationLevel,
    this.nextReligiousCommitment,
    this.nextNationality,
    this.nextHeight,
    this.swipeDirection = 0,
    this.swipeProgress = 0,
  });

  // ✅ هل الأنيميشن شغالة دلوقتي؟
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

    return SliverAppBar(
      expandedHeight: context.height * 0.85,
      pinned: true,
      floating: false,
      snap: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Stack(
          alignment: Alignment.center,
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
            Positioned(
              left: 0,
              child: AnimatedBeFirstButton(
                onTap: () {
                  context.pushNamed(AppRouter.kBoostAccountView);
                },
              ),
            ),
          ],
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: RepaintBoundary(
          // ✅ يعزل الـ repaint عن باقي الـ tree
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ========= الكارت الخلفي =========
              // ✅ يتبني بس لما الأنيميشن شغالة
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
                  ),
                ),

              // ========= الكارت الأمامي =========
              // ✅ نستخدم Transform واحد بدل اتنين
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translate(currentTranslateX, 0.0)
                  ..rotateZ(currentAngle),
                child: RepaintBoundary(
                  child: _FrontProfileCard(
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
// ✅ FRONT CARD — Widget مستقلة
// ═══════════════════════════════════════════════════════════════
class _FrontProfileCard extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    final double bottomRadius = 80 * swipeProgress;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ الصورة
        GestureDetector(
          onTap: () {
            if (images.isNotEmpty) {
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
            // ✅ Hero بس لما مفيش أنيميشن — يمنع conflict
            child: isAnimating
                ? AppImage(coverImage, fit: BoxFit.cover)
                : Hero(
                    tag: coverImage,
                    child: AppImage(coverImage, fit: BoxFit.cover),
                  ),
          ),
        ),

        // ✅ معلومات اليوزر
        Positioned(
          bottom: 60.h,
          right: 16.w,
          left: 16.w,
          child: _InfoCard(
            name: name,
            age: age,
            location: location,
            tagsjob: tagsjob,
            educationLevel: educationLevel,
            religiousCommitment: religiousCommitment,
            nationality: nationality,
            height: height,
            // ✅ أثناء الأنيميشن — نخفف الـ blur أو نشيله
            useBlur: !isAnimating,
            opacity: 0.18,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ BACK CARD — Widget مستقلة
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
  });

  @override
  Widget build(BuildContext context) {
    final String backCover = (nextImages != null && nextImages!.isNotEmpty)
        ? nextImages!.first
        : '';

    return Stack(
      fit: StackFit.expand,
      children: [
        if (backCover.isNotEmpty) AppImage(backCover, fit: BoxFit.cover),
        // ✅ ColoredBox أخف من Container
        const ColoredBox(color: Color(0x40000000)),

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
            // ✅ الكارت الخلفي — بدون blur دايماً (مش هيبان)
            useBlur: false,
            opacity: 0.14,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ✅ INFO CARD — الجزء اللي فيه الاسم والتاجات
//    بتتحكم في الـ blur حسب الأنيميشن
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
              Flexible(
                child: Text(
                  name,
                  style: Styles.textStyle18Bold.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Gap(5.w),
              if (age.isNotEmpty)
                Text(
                  "$age ${context.tr("age")}",
                  style: Styles.textStyle14.copyWith(color: Colors.white),
                ),
              if (name.isNotEmpty) ...[
                Gap(8.w),
                const Icon(Icons.verified, color: Colors.blue, size: 20),
              ],
            ],
          ),
          Gap(5.h),
          if (location.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.white, size: 16),
                Gap(5.w),
                Flexible(
                  child: Text(
                    location,
                    style: Styles.textStyle12.copyWith(color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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

  Widget _buildTag(String text) {
    // ✅ التاجات — بدون blur نهائي (مش محتاج + بيأثر على الأداء)
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(opacity),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.2),
      ),
      child: Text(
        text,
        style: Styles.textStyle10.copyWith(color: Colors.white),
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
      borderRadius: BorderRadius.circular(borderRadius),
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

    // ✅ لو مفيش blur — نشيل BackdropFilter خالص
    if (blur <= 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(paddingAll),
          decoration: decoration,
          child: child,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
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
