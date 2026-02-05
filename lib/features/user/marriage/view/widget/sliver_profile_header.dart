import 'dart:ui';
import 'package:tayseer/features/user/marriage/view/widget/animated_be_first_button.dart';
import 'package:tayseer/features/user/marriage/view/widget/image_viewer_gallery.dart';
import 'package:tayseer/my_import.dart';

class SliverProfileHeader extends StatelessWidget {
  final List<String> images;
  final String name;
  final String age;
  final String location;
  final String? tagsjob;
  final String? educationLevel;
  final String? religiousCommitment;
  final String? nationality;
  final String? height;
  final String? transitionKey;

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
    this.transitionKey,
  });

  @override
  Widget build(BuildContext context) {
    final String coverImage = images.isNotEmpty ? images.first : '';

    return SliverAppBar(
      expandedHeight: context.height * 0.85,
      pinned: false,
      floating: false,
      snap: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                context.pushNamed(AppRouter.kMarriageFilterView);
              },
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: AppImage(AssetsData.kfilterIcon, width: 20, height: 20),
              ),
            ),
            AnimatedBeFirstButton(
              onTap: () {
                context.pushNamed(AppRouter.kBoostAccountView);
              },
            ),
          ],
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                if (images.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageViewerGallery(images: images, initialIndex: 0),
                    ),
                  );
                }
              },
              child: Hero(
                tag: coverImage,
                child: AppImage(coverImage, fit: BoxFit.cover),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation =
                        Tween<Offset>(
                          begin: const Offset(0, 0.35),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Container(
                    key: ValueKey(transitionKey ?? name),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: Styles.textStyle18Bold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Gap(5.w),
                            Text(
                              "$age ${context.tr("age")}",
                              style: Styles.textStyle14.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            Gap(8.w),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ),
                        Gap(5.h),
                        Row(
                          children: [
                            const Icon(
                              Icons.flag,
                              color: Colors.white,
                              size: 16,
                            ),
                            Gap(5.w),
                            Text(
                              location,
                              style: Styles.textStyle12.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        Gap(10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            if (tagsjob != null && tagsjob!.isNotEmpty)
                              _buildTransparentTag(tagsjob!),
                            if (educationLevel != null &&
                                educationLevel!.isNotEmpty)
                              _buildTransparentTag(educationLevel!),
                            if (religiousCommitment != null &&
                                religiousCommitment!.isNotEmpty)
                              _buildTransparentTag(religiousCommitment!),
                            if (nationality != null && nationality!.isNotEmpty)
                              _buildTransparentTag(nationality!),
                          ],
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
