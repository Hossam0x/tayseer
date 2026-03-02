// lib/features/user/marriage/view/widget/sliver_profile_header.dart

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
    // الأمامي
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
    // الخلفي (اختياري)
    this.nextImages,
    this.nextName,
    this.nextAge,
    this.nextLocation,
    this.nextTagsjob,
    this.nextEducationLevel,
    this.nextReligiousCommitment,
    this.nextNationality,
    this.nextHeight,
    // أنيميشن
    this.swipeDirection = 0,
    this.swipeProgress = 0,
  });

  @override
  Widget build(BuildContext context) {
    final String coverImage = images.isNotEmpty ? images.first : '';
    final bool hasNext = nextName != null;

    // زاوية أقصى لفة 30 درجة
    final double maxAngleRad = 30 * math.pi / 180;

    // قيمة الزاوية الحالية حسب الـ progress والاتجاه
    final double currentAngle = swipeDirection * swipeProgress * maxAngleRad;

    // مسافة الطيران أفقياً
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
        background: Stack(
          fit: StackFit.expand,
          children: [
            // ========= الكارت الخلفي (اليوزر اللي بعده) =========
            if (hasNext) _buildBackProfileCard(context),

            // ========= الكارت الأمامي (اليوزر الحالي) مع اللفة والطيران =========
            Transform.translate(
              offset: Offset(currentTranslateX, 0),
              child: Transform.rotate(
                angle: currentAngle,
                alignment: Alignment.center,
                child: _buildFrontProfileCard(context, coverImage),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= FRONT CARD =================
  Widget _buildFrontProfileCard(BuildContext context, String coverImage) {
    // قيمة الـ border radius السفلي تكبر مع الـ progress
    final double bottomRadius = 80 * swipeProgress;

    return Stack(
      fit: StackFit.expand,
      children: [
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
            // ✅ الحواف السفلية بتتدور مع الـ swipeProgress
            borderRadius: BorderRadius.only(
              topLeft: Radius.zero,
              topRight: Radius.zero,
              bottomLeft: Radius.circular(bottomRadius),
              bottomRight: Radius.circular(bottomRadius),
            ),
            child: Hero(
              tag: coverImage,
              child: AppImage(coverImage, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          bottom: 60.h,
          right: 16.w,
          left: 16.w,
          child: glassCard(
            borderRadius: 24,
            blur: 18,
            opacity: 0.18,
            paddingAll: 16,
            child: _buildInfoContent(
              context,
              name: name,
              age: age,
              location: location,
              tagsjob: tagsjob,
              educationLevel: educationLevel,
              religiousCommitment: religiousCommitment,
              nationality: nationality,
              height: height,
            ),
          ),
        ),
      ],
    );
  }

  // ================= BACK CARD =================
  Widget _buildBackProfileCard(BuildContext context) {
    final String backCover = (nextImages != null && nextImages!.isNotEmpty)
        ? nextImages!.first
        : '';

    return Stack(
      fit: StackFit.expand,
      children: [
        // ممكن تستخدم صورة اليوزر اللي بعده كخلفية خفيفة
        if (backCover.isNotEmpty) AppImage(backCover, fit: BoxFit.cover),

        // Layer شفافة فوق عشان الكارت الأمامي يبقى واضح
        Container(color: Colors.black.withOpacity(0.25)),

        // الكارت الخلفي في نفس مكان الكارت الأمامي
        Positioned(
          bottom: 60.h,
          right: 16.w,
          left: 16.w,
          child: glassCard(
            borderRadius: 24,
            blur: 18,
            opacity: 0.14,
            paddingAll: 16,
            child: _buildInfoContent(
              context,
              name: nextName ?? '',
              age: nextAge ?? '',
              location: nextLocation ?? '',
              tagsjob: nextTagsjob,
              educationLevel: nextEducationLevel,
              religiousCommitment: nextReligiousCommitment,
              nationality: nextNationality,
              height: nextHeight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoContent(
    BuildContext context, {
    required String name,
    required String age,
    required String location,
    String? tagsjob,
    String? educationLevel,
    String? religiousCommitment,
    String? nationality,
    String? height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: Styles.textStyle18Bold.copyWith(color: Colors.white),
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
              Text(
                location,
                style: Styles.textStyle12.copyWith(color: Colors.white70),
              ),
            ],
          ),
        Gap(10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            if (tagsjob != null && tagsjob.isNotEmpty)
              _buildTransparentTag(tagsjob),
            if (educationLevel != null && educationLevel.isNotEmpty)
              _buildTransparentTag(educationLevel),
            if (religiousCommitment != null && religiousCommitment.isNotEmpty)
              _buildTransparentTag(religiousCommitment),
            if (nationality != null && nationality.isNotEmpty)
              _buildTransparentTag(nationality),
          ],
        ),
      ],
    );
  }

  Widget _buildTransparentTag(String text) {
    return glassCard(
      borderRadius: 24,
      blur: 18,
      opacity: 0.18,
      paddingAll: 6,
      child: Text(
        text,
        style: Styles.textStyle10.copyWith(color: Colors.white),
      ),
    );
  }

  Widget glassCard({
    required Widget child,
    double borderRadius = 20,
    double blur = 20,
    double opacity = 0.25,
    double paddingAll = 0.0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: EdgeInsets.all(paddingAll),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(opacity),
                Colors.white.withOpacity(opacity / 2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
