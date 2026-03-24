import 'package:tayseer/features/advisor/settings/data/models/blocked_user_model.dart';
import 'package:tayseer/features/advisor/settings/data/models/blocked_user_item.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/blocked_users/blocked_users_cubit.dart';
import 'package:tayseer/my_import.dart';

class BlockedUsersList extends StatelessWidget {
  final List<BlockedUserModel> blockedUsers;
  const BlockedUsersList({super.key, required this.blockedUsers});

  @override
  Widget build(BuildContext context) {
    if (blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.icNoContentSeach),
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
      onRefresh: () async => context.read<BlockedUsersCubit>().refresh(),
      color: AppColors.kprimaryColor,
      backgroundColor: AppColors.kWhiteColor,
      displacement: 40.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: blockedUsers.length,
        separatorBuilder: (_, __) =>
            Divider(color: Colors.grey.shade200, height: 1),
        itemBuilder: (context, index) {
          final user = blockedUsers[index];
          return BlockedUserItem(
            blockedUser: user,
            onUnblock: () => _showUnblockDialog(context, user),
          );
        },
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, BlockedUserModel blockedUser) {
    final cubit = context.read<BlockedUsersCubit>();
    CustomshowDialogWithImage(
      context,
      title: context.tr('unblock'),
      supTitle:
          '${context.tr('are_you_sure_unblock')} ${blockedUser.blockedUser.name}',
      icon: Icons.block,
      iconColor: AppColors.kprimaryColor,
      iconBackgroundColor: AppColors.primary100,
      bottonText: context.tr('yes'),
      onPressed: () => cubit.unblockUser(blockedUser.blockedUser.id),
      showCancelButton: true,
      cancelText: context.tr('no'),
      onCancel: () {},
    );
  }
}
