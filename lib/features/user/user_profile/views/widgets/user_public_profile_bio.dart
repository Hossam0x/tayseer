import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UserPublicProfileBio extends StatelessWidget {
  const UserPublicProfileBio({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      buildWhen: (previous, current) =>
          previous.profileState != current.profileState ||
          previous.profile != current.profile,
      builder: (context, state) {
        switch (state.profileState) {
          case CubitStates.loading:
            return SliverToBoxAdapter(child: _buildSkeletonBio(context));
          case CubitStates.failure:
            return _buildErrorBio(context, state.profileErrorMessage);
          case CubitStates.success:
            if (state.profile != null) {
              return SliverToBoxAdapter(
                child: _buildBioContent(context, state.profile!),
              );
            }
            return _buildEmptyBio();
          default:
            return _buildEmptyBio();
        }
      },
    );
  }

  Widget _buildSkeletonBio(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: _buildBioContent(
        context,
        const UserProfileModel(
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

  Widget _buildErrorBio(BuildContext context, String? errorMessage) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.kRedColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.kRedColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(Icons.info_outline, color: AppColors.kRedColor, size: 32.w),
            Gap(10.h),
            Text(
              errorMessage ?? 'حدث خطأ في تحميل البيانات',
              style: Styles.textStyle14.copyWith(color: AppColors.kRedColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioContent(BuildContext context, UserProfileModel profile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الاسم
          Text(
            profile.name,
            style: Styles.textStyle20SemiBold.copyWith(
              color: AppColors.blueText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Gap(4.h),

          // اسم المستخدم
          if (profile.username.isNotEmpty) ...[
            Text(
              profile.username,
              style: Styles.textStyle14.copyWith(color: AppColors.hintText),
            ),
            Gap(8.h),
          ],

          // حالة الجاهزية للزواج
          if (!profile.isMe) ...[
            profile.availableForMarry
                ? Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: CustomBotton(
                      width: 200.w,
                      height: 40.h,
                      backGroundcolor: AppColors.primary400,
                      title: 'رؤية ملف الزواج',
                      onPressed: () {
                        context.pushNamed(
                          AppRouter.kMarriageView,
                          arguments: {'personId': profile.id},
                        );
                      },
                    ),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary400,
                      borderRadius: BorderRadius.circular(34.r),
                    ),
                    child: Text(
                      'غير متاح',
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondary950,
                      ),
                    ),
                  ),
            Gap(12.h),
          ],

          // الوصف
          if (profile.description != null && profile.description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
              child: Text(
                profile.description!,
                style: Styles.textStyle14.copyWith(
                  color: AppColors.infoText,
                  height: 1.5,
                ),
                textAlign: TextAlign.start,
              ),
            ),

          // زر التواصل (إذا لم يكن المستخدم نفسه وكان جاهز للزواج)
          // if (!profile.isMe && profile.availableForMarry)
          // _buildContactButton(context),
        ],
      ),
    );
  }

  // Widget _buildContactButton(BuildContext context) {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 16.h),
  //     child: CustomBotton(
  //       height: 54.h,
  //       width: double.infinity,
  //       title: 'تواصل معي',
  //       onPressed: () {
  //         // TODO: افتح محادثة مع المستخدم
  //         // Navigator.pushNamed(context, AppRouter.ic);
  //       },
  //       backGroundcolor: AppColors.kprimaryColor,
  //       titleColor: AppColors.kWhiteColor,
  //       radius: 10.r,
  //       useGradient: true,
  //       elevation: 0,
  //     ),
  //   );
  // }

  SliverToBoxAdapter _buildEmptyBio() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
