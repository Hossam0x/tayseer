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
import 'package:tayseer/features/user/user_profile/views/widgets/user_public_profile_skeletonizer.dart';
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
                top: 55.h,
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
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocBuilder<UserPublicProfileCubit, UserPublicProfileState>(
      builder: (context, state) {
        final isBlocked = state.profile?.isBlockedByMe ?? false;
        if (state.profile?.isMe == true ||
            state.state != CubitStates.success ||
            state.profile == null ||
            isBlocked) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: FloatingActionButton(
            onPressed: () {
              if (isGuest) {
                CustomshowDialogWithImage(
                  context,
                  title: context.tr('joinUs'),
                  supTitle: context.tr("guest_login_first"),
                  icon: Icons.lock_person_outlined,
                  iconColor: AppColors.kprimaryColor,
                  bottonText: context.tr("login"),
                  showCancelButton: true,
                  cancelText: context.tr('skip'),
                  onPressed: () {
                    CachNetwork.removeData(key: ktoken);
                    context.pushNamedAndRemoveUntil(
                      AppRouter.kRegisrationView,
                      predicate: (_) => false,
                    );
                  },
                  onCancel: () {},
                );
                return;
              }

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
          return const UserPublicProfileViewSkeletonizer();
        }

        return RefreshIndicator.adaptive(
          onRefresh: () => context.read<UserPublicProfileCubit>().refresh(),
          color: AppColors.kprimaryColor,
          backgroundColor: AppColors.kWhiteColor,
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
}
