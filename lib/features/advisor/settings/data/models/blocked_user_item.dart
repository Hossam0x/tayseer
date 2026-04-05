import 'package:tayseer/core/enum/verification_type.dart';
import 'package:tayseer/features/advisor/settings/data/models/blocked_user_model.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/image_placeholder.dart';
import 'package:tayseer/my_import.dart';

class BlockedUserItem extends StatelessWidget {
  final BlockedUserModel blockedUser;
  final VoidCallback onUnblock;

  const BlockedUserItem({
    super.key,
    required this.blockedUser,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          // User Avatar
          _buildUserAvatar(),

          SizedBox(width: 12.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blockedUser.blockedUser.name,
                  style: Styles.textStyle16.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (blockedUser.blockedUser.verificationType ==
                    VerificationType.full)
                  Row(
                    children: [
                      SizedBox(width: 4.w),
                      Icon(Icons.verified, color: Colors.blue, size: 16.w),
                    ],
                  )
                else if (blockedUser.blockedUser.verificationType ==
                    VerificationType.basic)
                  Row(
                    children: [
                      SizedBox(width: 4.w),
                      Icon(Icons.verified, color: Colors.grey, size: 16.w),
                    ],
                  ),
                SizedBox(height: 2.h),
                Text(
                  blockedUser.blockedUser.userName,
                  style: Styles.textStyle14.copyWith(color: AppColors.gray2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // SizedBox(height: 4.h),
                // Text(
                //   _formatDate(blockedUser.createdAt),
                //   style: Styles.textStyle12.copyWith(
                //     color: AppColors.secondary400,
                //   ),
                // ),
              ],
            ),
          ),

          const Spacer(),

          // Unblock Button
          CustomBotton(
            title: context.tr('unblock'),
            onPressed: onUnblock,
            width: 105.w,
            height: 50.w,
            useGradient: true,
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    final imageUrl = blockedUser.blockedUser.image;

    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary100,
        border: Border.all(color: AppColors.secondary200, width: 1),
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    ImagePlaceholder(iconData: Icons.person, size: 24.w),
                errorWidget: (context, url, error) =>
                    ImagePlaceholder(iconData: Icons.person, size: 24.w),
              )
            : ImagePlaceholder(iconData: Icons.person, size: 24.w),
      ),
    );
  }

  // String _formatDate(DateTime date) {
  //   final now = DateTime.now();
  //   final difference = now.difference(date);

  //   if (difference.inDays > 365) {
  //     final years = (difference.inDays / 365).floor();
  //     return 'منذ $years ${years == 1 ? 'سنة' : 'سنوات'}';
  //   } else if (difference.inDays > 30) {
  //     final months = (difference.inDays / 30).floor();
  //     return 'منذ $months ${months == 1 ? 'شهر' : 'أشهر'}';
  //   } else if (difference.inDays > 0) {
  //     return 'منذ ${difference.inDays} ${difference.inDays == 1 ? 'يوم' : 'أيام'}';
  //   } else if (difference.inHours > 0) {
  //     return 'منذ ${difference.inHours} ${difference.inHours == 1 ? 'ساعة' : 'ساعات'}';
  //   } else if (difference.inMinutes > 0) {
  //     return 'منذ ${difference.inMinutes} ${difference.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
  //   } else {
  //     return 'الآن';
  //   }
  // }
}
