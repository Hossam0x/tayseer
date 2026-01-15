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
              CircleAvatar(
                radius: 28.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: AssetImage(AssetsData.avatarImage),
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
