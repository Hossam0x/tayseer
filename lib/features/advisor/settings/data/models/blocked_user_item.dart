import 'dart:ui';

import 'package:tayseer/my_import.dart';

class BlockedUserItem extends StatelessWidget {
  final String name;
  final String username;
  final String imageUrl;
  final VoidCallback onUnblock;

  const BlockedUserItem({
    super.key,
    required this.name,
    required this.username,
    required this.imageUrl,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(AssetsData.avatarImage, fit: BoxFit.cover),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(color: Colors.white.withOpacity(0.1)),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 12.w),
              // Right Side: Info and Avatar
              Column(
                children: [
                  Text(
                    name,
                    style: Styles.textStyle16.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary700,
                    ),
                  ),
                  Text(
                    username,
                    style: Styles.textStyle14.copyWith(color: AppColors.gray2),
                  ),
                ],
              ),

              const Spacer(),
              // Left Side: Unblock Button
              CustomBotton(
                title: 'الغاء الحظر',
                onPressed: onUnblock,
                width: 100.w,
                useGradient: true,
              ),
            ],
          ),
        ),
        // Divider line as seen in the image
        Divider(color: Colors.grey.shade200, height: 1),
      ],
    );
  }
}
