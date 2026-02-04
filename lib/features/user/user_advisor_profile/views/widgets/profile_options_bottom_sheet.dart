import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_profile_cubit.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/widgets/reposrt_bottom_sheet.dart';
import 'package:tayseer/my_import.dart';

class ProfileOptionsBottomSheet extends StatelessWidget {
  final String advisorId;
  final String? advisorName;
  final UserAdvisorProfileCubit cubit;

  const ProfileOptionsBottomSheet({
    super.key,
    required this.advisorId,
    this.advisorName,
    required this.cubit,
  });

  static void show(
    BuildContext context, {
    required String advisorId,
    String? advisorName,
    required UserAdvisorProfileCubit cubit,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProfileOptionsBottomSheet(
        advisorId: advisorId,
        advisorName: advisorName,
        cubit: cubit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<OptionItem> options = [
      OptionItem(
        // text: context.tr(AppStrings.shareProfile),
        text: context.tr('share_profile'),
        icon: Icons.ios_share_rounded,
        onTap: () => _handleShare(context),
      ),
      OptionItem(
        text: context.tr('block'),
        icon: Icons.block_outlined,
        onTap: () => _showBlockConfirmation(context),
        isDestructive: true,
        isBlock: true,
      ),
      OptionItem(
        text: context.tr('report'),
        icon: Icons.error_outline_rounded,
        onTap: () => _showReportConfirmation(context),
        isDestructive: true,
        isReport: true,
      ),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26.r),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10.h),
                    width: 100.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppColors.secondary50,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                ),
                ...options.asMap().entries.map((entry) {
                  int idx = entry.key;
                  OptionItem item = entry.value;
                  return Column(
                    children: [
                      _buildOptionTile(context, item),
                      if (idx != options.length - 1)
                        Divider(height: 1.h, color: AppColors.secondary50),
                    ],
                  );
                }),
                Gap(10.h),
              ],
            ),
          ),
          Gap(16.h),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 18.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26.r),
              ),
              child: Text(
                context.tr(AppStrings.cancel),
                textAlign: TextAlign.center,
                style: Styles.textStyle16SemiBold.copyWith(
                  color: AppColors.secondary800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, OptionItem item) {
    final Color finalColor = item.isDestructive
        ? Colors.red
        : (item.color ?? AppColors.secondary800);

    return InkWell(
      onTap: () {
        // الـ confirmation dialogs هتتعامل مع إغلاق الـ sheet داخلها
        if (item.isBlock || item.isReport) {
          item.onTap?.call();
        } else {
          Navigator.pop(context);
          item.onTap?.call();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Row(
          children: [
            Icon(item.icon, size: 20.sp, color: finalColor),
            Gap(16.w),
            Text(
              item.text,
              style: Styles.textStyle16SemiBold.copyWith(color: finalColor),
            ),
          ],
        ),
      ),
    );
  }

  void _handleShare(BuildContext context) {
    // TODO: ضع هنا الـ logic بتاعة مشاركة الرابط
    // مثال:
    "https://tayseer.app/profile/$advisorId";
    // Share.share(profileLink, subject: "تعرف على $advisorName");
    showSafeSnackBar(
      context: context,
      text: context.tr('copied_to_clipboard'),
      isSuccess: true,
    );
  }

  void _showBlockConfirmation(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr(AppStrings.blockUser),
      supTitle: context.tr(AppStrings.blockUserConfirmation),
      icon: Icons.block,
      bottonText: context.tr(AppStrings.yes),
      onPressed: () async {
        final scaffoldContext = context;

        Navigator.pop(context); // dialog
        Navigator.pop(context); // sheet

        await cubit.blockUser(advisorId);

        final state = cubit.state;

        if (!scaffoldContext.mounted) return;

        if (state.blockActionState == CubitStates.success) {
          showSafeSnackBar(
            context: scaffoldContext,
            text: state.blockMessage ?? context.tr('blocked_successfully'),
            isSuccess: true,
          );
        } else {
          showSafeSnackBar(
            context: scaffoldContext,
            text: state.blockMessage ?? context.tr('failed_to_block'),
            isError: true,
          );
        }
      },
      showCancelButton: true,
      cancelText: context.tr(AppStrings.no),
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  // للـ Report: بدلاً من confirmation بسيط، افتح bottom sheet جديدة
  void _showReportConfirmation(BuildContext context) {
    // افتح الـ ReportBottomSheet الجديدة
    ReportBottomSheet.show(context, reportedId: advisorId, cubit: cubit);
  }
}

class OptionItem {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isBlock;
  final bool isReport;
  final Color? color;

  OptionItem({
    required this.text,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
    this.isBlock = false,
    this.isReport = false,
    this.color,
  });
}
