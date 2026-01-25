// features/user/user_profile/views/user_public_profile_view.dart
import 'package:tayseer/features/user/user_profile/data/repositories/user_posts_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_bio.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_header.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_tabs.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileView extends StatelessWidget {
  final String userId; // ⭐ تغيير: من UserProfileModel إلى String

  const UserPublicProfileView({super.key, required this.userId}); // ⭐ تحديث

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            // المحتوى الرئيسي
            SafeArea(
              child: BlocProvider<UserPublicProfileCubit>(
                create: (_) => UserPublicProfileCubit(
                  getIt<UserPublicProfileRepository>(),
                  getIt<UserPostsRepository>(),
                  userId: userId, // ⭐ تمرير userId فقط
                  initialProfile: null, // ⭐ لا توجد بيانات أولية
                ),
                child: const _UserPublicProfileContent(),
              ),
            ),

            // زر الرجوع
            Positioned(
              top: 40.h,
              right: 8.w,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.secondary600,
                  size: 24.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserPublicProfileContent extends StatelessWidget {
  const _UserPublicProfileContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      builder: (context, state) {
        // ⭐ التحقق من حالة التحميل العامة
        if (state.state == CubitStates.loading) {
          return _buildLoadingSkeleton();
        }

        return RefreshIndicator.adaptive(
          onRefresh: () => context.read<UserPublicProfileCubit>().refresh(),
          color: AppColors.kprimaryColor,
          backgroundColor: AppColors.kWhiteColor,
          displacement: 40.h,
          edgeOffset: 0,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // الهيدر
              const UserPublicProfileHeader(),

              // المعلومات الشخصية
              const UserPublicProfileBio(),

              // Spacing
              SliverToBoxAdapter(child: Gap(20.h)),

              // التبويبات
              const UserPublicProfileTabs(),

              // مساحة في الأسفل
              SliverToBoxAdapter(child: Gap(100.h)),
            ],
          ),
        );
      },
    );
  }

  // ⭐ دالة جديدة لعرض Skeleton أثناء التحميل
  Widget _buildLoadingSkeleton() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Column(
              children: [
                // Skeleton للهيدر
                Row(
                  children: [
                    Gap(20.w),
                    Container(
                      width: 90.w,
                      height: 90.w,
                      decoration: BoxDecoration(
                        color: AppColors.secondary200,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap(55.w),
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: AppColors.secondary200,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: AppColors.secondary200,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                Gap(24.h),

                // Skeleton للبيو
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 150.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: AppColors.secondary200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      Gap(8.h),
                      Container(
                        width: 100.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColors.secondary200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      Gap(12.h),
                      Container(
                        width: 80.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: AppColors.secondary200,
                          borderRadius: BorderRadius.circular(34.r),
                        ),
                      ),
                      Gap(16.h),
                      Container(
                        width: double.infinity,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: AppColors.secondary200,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
