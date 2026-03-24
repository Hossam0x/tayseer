import 'package:tayseer/my_import.dart';

class HideStoryUserItem extends StatelessWidget {
  final dynamic user;
  final VoidCallback onTap;

  const HideStoryUserItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: user.image != null && user.image!.isNotEmpty
                  ? NetworkImage(user.image!) as ImageProvider
                  : AssetImage(AssetsData.avatarImage),
              child: user.image == null || user.image!.isEmpty
                  ? Icon(Icons.person, color: Colors.grey.shade400, size: 24.sp)
                  : null,
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Styles.textStyle16.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary800,
                    ),
                  ),
                  if (user.userName.isNotEmpty)
                    Text(
                      user.userName,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.gray2,
                      ),
                    ),
                  if (user.email != null && user.email!.isNotEmpty)
                    Text(
                      user.email!,
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.gray2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: user.isSelected
                    ? const Color(0xFFD65670)
                    : Colors.transparent,
                border: Border.all(
                  color: user.isSelected
                      ? const Color(0xFFD65670)
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: user.isSelected
                  ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
