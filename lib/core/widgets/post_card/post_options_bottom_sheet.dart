import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/my_import.dart';

class PostOptionsBottomSheet extends StatelessWidget {
  final PostModel? post;

  final VoidCallback? onShare;
  final VoidCallback? onReport;
  final VoidCallback? onBlock;
  final VoidCallback? onHide;
  final VoidCallback? onSave;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;

  const PostOptionsBottomSheet({
    super.key,
    required this.post,
    this.onShare,
    this.onReport,
    this.onBlock,
    this.onHide,
    this.onSave,
    this.onEdit,
    this.onArchive,
    this.onDelete,
  });

  static void show(
    BuildContext context, {
    required PostModel post,
    VoidCallback? onShare,
    VoidCallback? onReport,
    VoidCallback? onBlock,
    VoidCallback? onHide,
    VoidCallback? onSave,
    VoidCallback? onEdit,
    VoidCallback? onArchive,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PostOptionsBottomSheet(
        post: post,
        onShare: onShare,
        onReport: onReport,
        onBlock: onBlock,
        onHide: onHide,
        onSave: onSave,
        onEdit: onEdit,
        onArchive: onArchive,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaved = post?.isSaved ?? false;

    final List<OptionItem> options = post?.isMine ?? false
        ? [
            OptionItem(
              text: context.tr(AppStrings.share),
              // مربع طالع منه سهم (زي الآيفون) ومفرغ
              icon: Icons.ios_share_rounded,
              onTap: onShare,
            ),
            OptionItem(
              text: context.tr(AppStrings.edit),
              // دي أقرب أيقونة ماتيريال (قلم جوه مربع) وتكون مفرغة
              icon: Icons.drive_file_rename_outline_rounded,
              onTap: onEdit,
            ),
            OptionItem(
              text: context.tr(AppStrings.archive),
              // صندوق الأرشيف المفرغ
              icon: Icons.archive_outlined,
              onTap: onArchive,
            ),
            OptionItem(
              text: context.tr(AppStrings.delete),
              // سلة المهملات المفرغة
              icon: Icons.delete_outline_rounded,
              onTap: onDelete,
              isDestructive: true,
              isDelete: true,
            ),
          ]
        : [
            OptionItem(
              text: context.tr(AppStrings.share),
              icon: Icons.ios_share_rounded,
              onTap: onShare,
            ),
            OptionItem(
              text: context.tr(AppStrings.report),
              // دائرة جواها علامة تعجب مفرغة
              icon: Icons.error_outline_rounded,
              onTap: onReport,
            ),
            OptionItem(
              text: context.tr(AppStrings.block),
              // دائرة الحظر المفرغة
              icon: Icons.block_outlined,
              onTap: onBlock,
            ),
            OptionItem(
              text: context.tr(AppStrings.hide),
              // مربع جواه علامة X مفرغ (أقرب حاجة رسمية في ماتيريال)
              icon: Icons.cancel_presentation_outlined,
              // أو ممكن تستخدم Icons.disabled_visible_outlined (شكل العين وعليها خط) وهو الدارج للإخفاء
              onTap: onHide,
            ),
            OptionItem(
              text: context.tr(AppStrings.save),
              // التبديل بين الـ Bookmark المفرغة والممتلئة
              icon: isSaved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: isSaved ? AppColors.kprimaryColor : null,
              onTap: onSave,
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
    // تحديد اللون النهائي
    final Color finalColor = item.isDestructive
        ? Colors.red
        : (item.color ?? AppColors.secondary800);

    return InkWell(
      onTap: () {
        if (item.isDelete) {
          _showDeleteConfirmation(context); // ✅ نمرر context الـ BottomSheet
        } else {
          Navigator.pop(context);
          if (item.onTap != null) item.onTap!();
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Row(
          children: [
            // أيقونات FontAwesome حجم 20 مناسب جداً للنصوص
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

  void _showDeleteConfirmation(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr(AppStrings.deletePost),
      supTitle: context.tr(AppStrings.deletePostConfirmation),
      imageUrl: AssetsData.deleteIcon,
      bottonText: context.tr(AppStrings.yes),
      onPressed: () {
        Navigator.pop(context); // أغلق الديالوج
        if (onDelete != null) onDelete!(); // ✅ نفذ الحذف
      },
      showCancelButton: true,
      cancelText: context.tr(AppStrings.no),
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }
}

class OptionItem {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool isDelete;
  final Color? color;

  OptionItem({
    required this.text,
    required this.icon,
    this.isDelete = false,
    this.onTap,
    this.isDestructive = false,
    this.color,
  });
}
