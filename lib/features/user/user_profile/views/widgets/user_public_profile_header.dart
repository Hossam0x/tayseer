import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/features/shared/followers/user_followings_view.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserPublicProfileHeader extends StatelessWidget {
  const UserPublicProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      buildWhen: (previous, current) =>
          previous.state != current.state || // ⭐ مراقبة state العامة
          previous.profile != current.profile,
      builder: (context, state) {
        // ⭐ التحقق من الحالة العامة أولاً
        if (state.state == CubitStates.loading) {
          return SliverToBoxAdapter(child: _buildSkeletonHeader(context));
        }

        if (state.state == CubitStates.failure) {
          return SliverToBoxAdapter(
            child: _buildErrorHeader(context, state.profileErrorMessage),
          );
        }

        if (state.profile != null) {
          return SliverToBoxAdapter(
            child: _buildProfileHeader(context, state.profile!),
          );
        }

        return _buildEmptyHeader();
      },
    );
  }

  Widget _buildSkeletonHeader(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildHeaderContent(
        imageUrl: '',
        following: '0',
        context: context,
        profile: const UserProfileModel(
          id: '',
          name: 'اسم المستخدم',
          username: '@username',
          description: 'وصف المستخدم',
          image: '',
          following: 0,
          isMe: false,
          age: 0,
          gender: 'ذكر',
          isAnonymous: false,
          availableForMarry: false,
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileModel profile) {
    return _buildHeaderContent(
      imageUrl: profile.image ?? '',
      following: profile.following.toString(),
      context: context,
      profile: profile,
    );
  }

  Widget _buildErrorHeader(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Gap(40.h),
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Text(
              errorMessage ?? 'حدث خطأ أثناء تحميل البيانات',
              style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
              textAlign: TextAlign.center,
            ),
          ),
          Gap(10.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () =>
                context.read<UserPublicProfileCubit>().fetchProfile(),
            child: Text(
              'إعادة المحاولة',
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent({
    required String imageUrl,
    required String following,
    required BuildContext context,
    required UserProfileModel profile,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        children: [
          Gap(20.w),
          // الصورة الشخصية
          SizedBox(
            width: 90.w,
            height: 90.w,
            child: Stack(
              children: [MyProfileImage(width: 90.w, imageUrl: imageUrl)],
            ),
          ),
          Gap(55.w),

          // الإحصائيات
          _buildStatsItem(
            value: following,
            label: 'متابَع',
            onTap: () {},
            userId: profile.id,
            context: context,
          ),
          Spacer(),
          if (!profile.isMe)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildMoreButton(context),
                SizedBox(height: 40.w),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatsItem({
    required String value,
    required String label,
    required VoidCallback onTap,
    required BuildContext context,
    required String userId,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserFollowingsView(userId: userId),
        ),
      ),
      child: Column(
        children: [
          Text(value, style: Styles.textStyle16SemiBold),
          Text(label, style: Styles.textStyle14),
        ],
      ),
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMoreOptions(context),
      child: Icon(Icons.more_vert, color: AppColors.secondary600, size: 28.w),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final cubit = context.read<UserPublicProfileCubit>();
    final state = cubit.state;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر المشاركة
            ListTile(
              leading: Icon(Icons.share, color: AppColors.kprimaryColor),
              title: Text('مشاركة البروفايل', style: Styles.textStyle16),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),

            // زر الحظر (إذا لم يكن المستخدم نفسه)
            if (!state.profile!.isMe)
              ListTile(
                leading: Icon(Icons.block, color: AppColors.kRedColor),
                title: Text('حظر المستخدم', style: Styles.textStyle16),
                onTap: () {
                  Navigator.pop(context);
                  _showBlockConfirmation(context);
                },
              ),

            // زر الإبلاغ (إذا لم يكن المستخدم نفسه)
            if (!state.profile!.isMe)
              ListTile(
                leading: Icon(Icons.report, color: AppColors.kRedColor),
                title: Text('الإبلاغ', style: Styles.textStyle16),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(context);
                },
              ),

            // زر حذف الحساب (إذا كان المستخدم نفسه)
            if (state.profile!.isMe)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.kRedColor),
                title: Text(
                  'حذف الحساب',
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.kRedColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteAccountConfirmation(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حظر المستخدم', style: Styles.textStyle18Bold),
        content: Text(
          'هل أنت متأكد من حظر هذا المستخدم؟ لن تتمكن من رؤية منشوراته أو التواصل معه.',
          style: Styles.textStyle14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: Styles.textStyle14),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement block functionality
              AppToast.success(context, 'تم حظر المستخدم بنجاح');
            },
            child: Text(
              'حظر',
              style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الحساب', style: Styles.textStyle18Bold),
        content: Text(
          'هل أنت متأكد من حذف حسابك؟ هذه العملية لا يمكن التراجع عنها.',
          style: Styles.textStyle14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: Styles.textStyle14),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final cubit = context.read<UserPublicProfileCubit>();
              await cubit.deleteUserAccount();

              // بعد الحذف، ارجع للصفحة الرئيسية
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRouter.kRegisrationView,
                (route) => false,
              );
            },
            child: Text(
              'حذف',
              style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الإبلاغ عن المستخدم', style: Styles.textStyle18Bold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('اختر السبب:', style: Styles.textStyle14Meduim),
            Gap(12.h),
            ...['محتوى غير لائق', 'تصرف مزعج', 'حساب وهمي', 'سبب آخر'].map(
              (reason) => ListTile(
                title: Text(reason, style: Styles.textStyle14),
                onTap: () {
                  Navigator.pop(context);
                  AppToast.success(context, 'تم الإبلاغ بنجاح');
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: Styles.textStyle14),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyHeader() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
