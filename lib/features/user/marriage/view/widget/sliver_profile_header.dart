import 'dart:ui';

import 'package:tayseer/my_import.dart';

class SliverProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final int age;
  final String location;
  final List<dynamic> tags;

  const SliverProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.age,
    required this.location,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: context.height * 0.85,
      pinned: true,
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
              onTap: () {},
              child: CircleAvatar(
                backgroundColor: Colors.black26,
                child: AppImage(AssetsData.kfilterIcon, width: 20, height: 20),
              ),
            ),

            GestureDetector(
              onTap: () {},
              child: AppImage(AssetsData.koneIcon, width: 30, height: 30),
            ),
          ],
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(imageUrl, fit: BoxFit.cover),

            Positioned(
              bottom: 20.h,
              right: 16.w,
              left: 16.w,
              child: glassCard(
                borderRadius: 24,
                blur: 18,
                opacity: 0.18,
                paddingAll: 16,
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
                        const Icon(Icons.flag, color: Colors.white, size: 16),
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
                    Row(
                      children: tags
                          .map(
                            (tag) => Padding(
                              padding: EdgeInsets.only(left: 5.w),
                              child: _buildTransparentTag(
                                tag['label'],
                                tag['icon'],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    Gap(20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCircleButton(
                          Icons.check,
                          AppColors.kprimaryTextColor,
                          HexColor('f8d3da'),
                        ),
                        _buildCircleButton(
                          Icons.star,
                          Colors.white,
                          HexColor('cccab3'),
                        ),

                        _buildCircleButton(
                          Icons.close,
                          Colors.white,
                          HexColor('e44e6c'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransparentTag(String text, String icon) {
    return glassCard(
      borderRadius: 24,
      blur: 18,
      opacity: 0.18,
      paddingAll: 6,
      child: Row(
        children: [
          AppImage(icon, gradientColorSvg: AppColors.linearGradientIcon),
          Gap(4.w),
          Text(text, style: Styles.textStyle10.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, Color iconColor, Color bgColor) {
    return CircleAvatar(
      radius: 28.r,
      backgroundColor: bgColor,
      child: Icon(icon, color: iconColor, size: 30),
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
