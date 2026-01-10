import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/my_import.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Profile picture
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  AppRouter.kAddPostView,
                  arguments: AddPostEnum.story,
                );
              },
              child: Stack(
                children: [
                  Container(
                    width: 85.w,
                    height: 85.w,
                    decoration: BoxDecoration(shape: BoxShape.circle),
                    child: ClipOval(
                      child: AppImage(
                        AssetsData.avatarImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: AppColors.kprimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: AppImage(
                          width: 18.w,
                          AssetsData.icAdd,
                          color: AppColors.kWhiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Top bar with followers/following
            Column(
              children: [
                Text("9,101", style: Styles.textStyle16SemiBold),
                Text("Following", style: Styles.textStyle14),
              ],
            ),
            Column(
              children: [
                Text("5,678", style: Styles.textStyle16SemiBold),
                Text("Followers", style: Styles.textStyle14),
              ],
            ),

            // Settings
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.all(9.w),
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary100,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: AppImage(AssetsData.settingsIcon),
                  ),
                ),
                SizedBox(height: 40.w),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
