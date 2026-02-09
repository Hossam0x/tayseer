// features/user/user_profile/views/user_public_profile_view.dart
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_posts_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/send_greeting_dialog.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_bio.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_header.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_tabs.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileView extends StatelessWidget {
  final String userId;

  const UserPublicProfileView({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        context.read<LanguageCubit>().state.languageCode == 'ar';
    return BlocProvider<UserPublicProfileCubit>(
      create: (_) => UserPublicProfileCubit(
        getIt<UserPublicProfileRepository>(),
        getIt<UserPostsRepository>(),
        userId: userId,
        initialProfile: null,
      ),
      child: Scaffold(
        body: AdvisorBackground(
          child: Stack(
            children: [
              // المحتوى الرئيسي
              const SafeArea(child: _UserPublicProfileContent()),

              // زر الرجوع
              // According language direction ar or en
              Positioned(
                top: 40.h,
                right: isArabic ? 8.w : null,
                left: !isArabic ? 8.w : null,
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

        // FloatingActionButton الآن داخل BlocProvider
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      builder: (context, state) {
        // لا يظهر الزر إذا كان هو نفسه أو إذا لم يتم تحميل البيانات بعد
        if (state.profile?.isMe == true ||
            state.state != CubitStates.success ||
            state.profile == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: FloatingActionButton(
            onPressed: () {
              final cubit = context.read<UserPublicProfileCubit>();
              SendGreetingDialog.show(
                context,
                receiverName: state.profile!.name,
                receiverId: state.profile!.id,
                cubit: cubit,
              );
            },
            backgroundColor: AppColors.kprimaryColor,
            shape: const CircleBorder(),
            elevation: 4,
            highlightElevation: 8,
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.kprimaryColor.withOpacity(0.9),
                    AppColors.kprimaryColor,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kprimaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: SvgPicture.asset(
                  AssetsData.icSendGreeting,
                  width: 26.w,
                  height: 26.w,
                  color: Colors.white,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
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
