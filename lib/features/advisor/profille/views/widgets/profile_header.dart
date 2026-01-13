import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/utils/animation/slide_right_animation.dart';
import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/settings/view/settings_view.dart';
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
                Navigator.pushNamed(
                  context,
                  AppRouter.kAddPostView,
                  arguments: AddPostEnum.story,
                );
              },
              child: Stack(
                children: [
                  MyProfileImage(width: 85.w),
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
                          width: 10.w,
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
                GestureDetector(
                  onTap: () => _openSettings(context),
                  child: Container(
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
                ),
                SizedBox(height: 40.w),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      SlideLeftRoute(
        page: const SettingsView(),
        routeSettings: const RouteSettings(name: AppRouter.kSettingsView),
      ),
    );
  }
}
