// lib/core/widgets/user_info_header.dart
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/my_import.dart';
// import your styles and assets...

class UserInfoHeader extends StatelessWidget {
  final String avatar;
  final String name;
  final bool isVerified;
  final Widget? subtitle; // خليناه ويدجت عشان المرونة (نص، تاريخ، ايقونات)
  final VoidCallback? onMoreTap;
  final String advisorId;
  final bool isFromProfile;

  const UserInfoHeader({
    super.key,
    required this.avatar,
    required this.name,
    required this.advisorId,
    this.isVerified = false,
    this.subtitle,
    this.onMoreTap,
    required this.isFromProfile,
  });

  void _navigateToUserProfile(BuildContext context) {
    // التحقق من أن هذا ليس بروفايل المستخدم الحالي
    // يمكنك استخدام getIt أو أي طريقة أخرى للتحقق من الـ current user id

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            UserAdvisorProfileView(advisorId: advisorId, advisorName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // تجميع الصورة والاسم في GestureDetector واحد
        Expanded(
          child: GestureDetector(
            onTap: () => isFromProfile ? null : _navigateToUserProfile(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(shape: BoxShape.circle),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: AppImage(avatar, fit: BoxFit.cover),
                  ),
                ),
                Gap(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: Styles.textStyle16SemiBold.copyWith(
                                color: HexColor("#19295C"),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            Gap(4.w),
                            Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 16.sp,
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[Gap(2.h), subtitle!],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onMoreTap != null)
          InkWell(
            onTap: onMoreTap,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_horiz,
                color: AppColors.kGreyB3,
                size: 26.sp,
              ),
            ),
          ),
      ],
    );
  }
}
