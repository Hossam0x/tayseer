import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/data/models/blocked_user_item.dart';
import 'package:tayseer/features/advisor/settings/data/models/blocked_user_model.dart';
import 'package:tayseer/features/advisor/settings/data/repositories/blocked_users_repository.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/blocked_users_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/blocked_users_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/custom_error_widget.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';

class BlockedUsersView extends StatefulWidget {
  const BlockedUsersView({super.key});

  @override
  State<BlockedUsersView> createState() => _BlockedUsersViewState();
}

class _BlockedUsersViewState extends State<BlockedUsersView> {
  late BlockedUsersCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = BlockedUsersCubit(getIt<BlockedUsersRepository>());
    // تحديث تلقائي كل 30 ثانية
    // _cubit.startAutoRefresh(const Duration(seconds: 60));
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _cubit,
      child: Scaffold(
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 105.h,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AssetsData.homeBarBackgroundImage),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // --- Custom Header ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      child: SimpleAppBar(title: context.tr('blocks')),
                    ),

                    // --- Main Content ---
                    Expanded(
                      child: BlocBuilder<BlockedUsersCubit, BlockedUsersState>(
                        builder: (context, state) {
                          return _buildContent(context, state);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BlockedUsersState state) {
    if (state is BlockedUsersLoading) {
      return _buildLoadingSkeleton();
    }

    if (state is BlockedUsersError) {
      return CustomErrorWidget(
        message: state.message,
        onRetry: () => context.read<BlockedUsersCubit>().refresh(),
      );
    }

    if (state is BlockedUsersLoaded) {
      return _buildBlockedUsersList(context, state.blockedUsers);
    }

    return const SizedBox();
  }

  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: 8,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              children: [
                // صورة السكلتون الدائرية
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                ),
                SizedBox(width: 12.w),
                // معلومات السكلتون
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 80.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // زر السكلتون
                Container(
                  width: 100.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlockedUsersList(
    BuildContext context,
    List<BlockedUserModel> blockedUsers,
  ) {
    if (blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AssetsData.emptyChatImage, width: 120.w, height: 120.w),
            SizedBox(height: 16.h),
            Text(
              context.tr('no_blocked_users'),
              style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        await context.read<BlockedUsersCubit>().refresh();
      },
      color: AppColors.kprimaryColor,
      backgroundColor: AppColors.kWhiteColor,
      displacement: 40.h,
      edgeOffset: 0,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: blockedUsers.length,
        separatorBuilder: (context, index) =>
            Divider(color: Colors.grey.shade200, height: 1),
        itemBuilder: (context, index) {
          final blockedUser = blockedUsers[index];
          return BlockedUserItem(
            blockedUser: blockedUser,
            onUnblock: () {
              _showUnblockConfirmation(context, blockedUser);
            },
          );
        },
      ),
    );
  }

  void _showUnblockConfirmation(
    BuildContext context,
    BlockedUserModel blockedUser,
  ) {
    final cubit = context.read<BlockedUsersCubit>();

    CustomshowDialogWithImage(
      context,
      title: context.tr('unblock'),
      supTitle: '${context.tr('are_you_sure_unblock')} ${blockedUser.blockedUser.name}؟',
      icon: Icons.block,
      iconColor: AppColors.kprimaryColor,
      iconBackgroundColor: AppColors.primary100,
      bottonText: context.tr('yes'),
      onPressed: () {
        cubit.unblockUser(blockedUser.blockedUser.id, context);
      },
      showCancelButton: true,
      cancelText: context.tr('no'),
      onCancel: () {},
    );
  }
}
