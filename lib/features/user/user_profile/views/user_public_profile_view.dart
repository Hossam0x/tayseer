// features/user/user_profile/views/user_public_profile_view.dart
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_posts_repository.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_public_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_public_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_bio.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_header.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_tabs.dart';
import 'package:tayseer/my_import.dart';

class UserPublicProfileView extends StatelessWidget {
  final UserProfileModel userProfile;

  const UserPublicProfileView({super.key, required this.userProfile});

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
                  userId: userProfile.id,
                  initialProfile: userProfile,
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
  }
}
