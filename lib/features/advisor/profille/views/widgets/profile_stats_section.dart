import 'package:tayseer/my_import.dart';

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 15.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatItem(context, "Will Byers"),
            Gap(24.w),
            _buildStatItem(context, "Millie Brown"),
            Gap(24.w),
            _buildStatItem(context, "Rachel Podrez"),
            Gap(24.w),
            _buildStatItem(context, "Robin Buckley"),
            // Gap(24.w),
            // _buildStatItem(context, "Will Byers"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30.r,
          backgroundColor: Colors.pink.withOpacity(0.2),
          child: ClipOval(
            child: AppImage(
              AssetsData.avatarImage,
              fit: BoxFit.cover,
              width: 60.w,
              height: 60.w,
            ),
          ),
        ),
        Gap(8.h),
        Text(
          name,
          style: Styles.textStyle12.copyWith(color: Colors.black),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
