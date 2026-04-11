import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tayseer/my_import.dart';

class LocationLockWidget extends StatelessWidget {
  const LocationLockWidget({
    super.key,
    required this.message,
    required this.description,
    this.onTap,
    this.titleBott = 'فتح الإعدادات',
    this.showBackgroundImage = true,
  });

  final String message;
  final String description;
  final VoidCallback? onTap;
  final String titleBott;
  final bool showBackgroundImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          if (showBackgroundImage)
            AppImage(
              AssetsData.homeBarBackgroundImage,
              width: MediaQuery.sizeOf(context).width,
              height: MediaQuery.sizeOf(context).height * 0.05,
              fit: BoxFit.cover,
            ),
          SafeArea(
            bottom: false,
            top: !showBackgroundImage,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.maybePop(context),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Transform.flip(
                      flipX: Directionality.of(context) == TextDirection.ltr,
                      child: AppImage(AssetsData.backArrow, width: 19),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_rounded,
                    size: 100,
                    color: AppColors.primary100,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: AppColors.kTextGrey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kGrey666,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomBotton(
                    radius: 16,
                    useGradient: true,
                    title: titleBott,
                    onPressed: onTap ?? () => Geolocator.openAppSettings(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 90.0), // spacer for bottom nav
        ],
      ),
    );
  }
}
