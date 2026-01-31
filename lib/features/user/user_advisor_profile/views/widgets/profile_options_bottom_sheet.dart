import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/my_import.dart';

class ProfileOptionsBottomSheet extends StatelessWidget {
  final String advisorId;
  final String? advisorName;

  const ProfileOptionsBottomSheet({
    super.key,
    required this.advisorId,
    this.advisorName,
  });

  static void show(
    BuildContext context, {
    required String advisorId,
    String? advisorName,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ProfileOptionsBottomSheet(
        advisorId: advisorId,
        advisorName: advisorName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<OptionItem> options = [
      OptionItem(
        // text: context.tr(AppStrings.shareProfile),
        text: 'مشاركة الملف الشخصي',
        icon: Icons.ios_share_rounded,
        onTap: () => _handleShare(context),
      ),
      OptionItem(
        text: context.tr(AppStrings.blockUser),
        icon: Icons.block_outlined,
        onTap: () => _showBlockConfirmation(context),
        isDestructive: true,
        isBlock: true,
      ),
      OptionItem(
        text: context.tr(AppStrings.report),
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
      text: "تم نسخ رابط البروفايل",
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
      onPressed: () {
        // هنا نفذ الـ API بتاعة Block
        // مثال:
        // context.read<UserAdvisorProfileCubit>().blockUser(advisorId);
        showSafeSnackBar(
          context: context,
          text: "تم حظر المستخدم",
          isSuccess: true,
        );
        Navigator.pop(context); // إغلاق الـ dialog
        Navigator.pop(context); // إغلاق الـ bottom sheet
      },
      showCancelButton: true,
      cancelText: context.tr(AppStrings.no),
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  void _showReportConfirmation(BuildContext context) {
    // هنا ممكن تعمل dialog أكثر تعقيداً فيه اختيار سبب + تفاصيل
    // لكن حالياً هنعمل بسيط
    CustomshowDialogWithImage(
      context,
      title: 'إبلاغ',
      supTitle: "هل أنت متأكد من الإبلاغ عن هذا المستخدم؟",
      icon: Icons.report,
      bottonText: context.tr(AppStrings.report),
      onPressed: () {
        // TODO: نفذ API الإبلاغ
        // مثال:
        // await _reportUser(context, advisorId, reason: "سبب عام", details: "");
        showSafeSnackBar(
          context: context,
          text: "تم إرسال الإبلاغ بنجاح",
          isSuccess: true,
        );
        Navigator.pop(context); // dialog
        Navigator.pop(context); // bottom sheet
      },
      showCancelButton: true,
      cancelText: context.tr(AppStrings.cancel),
      onCancel: () => Navigator.pop(context),
    );
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
