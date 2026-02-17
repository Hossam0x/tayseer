import 'package:tayseer/core/widgets/my_profile_Image.dart';
import 'package:tayseer/my_import.dart';

class CommentAvatar extends StatelessWidget {
  const CommentAvatar({
    super.key,
    required this.iscommented,
    this.isAnonymous,
    required this.currentSelection,
    required this.onSelectionChanged,
  });

  final bool iscommented;
  final bool? isAnonymous;
  final bool currentSelection;
  final ValueChanged<bool> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (iscommented) {
      return MyProfileImage(isAnnonymous: isAnonymous ?? false);
    }

    return GestureDetector(
      onTap: () => _showAvatarMenu(context),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          MyProfileImage(isAnnonymous: currentSelection),
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xffF2F2F2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 10.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarMenu(BuildContext context) async {
    // 1️⃣ اقفل الكيبورد عشان الشكل يبقى أحسن
    FocusScope.of(context).unfocus();

    // 2️⃣ اعرض BottomSheet بدل الـ Menu العائمة
    final bool? value = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(10.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Gap(20.h),
            _buildOption(
              context,
              isAnonymous: false,
              title: kCurrentUserData?.name ?? context.tr(AppStrings.general),
              isSelected: !currentSelection,
            ),
            Divider(height: 1, color: Colors.grey.shade100),
            _buildOption(
              context,
              isAnonymous: true,
              title: context.tr(AppStrings.anonymous),
              isSelected: currentSelection,
            ),
            Gap(20.h),
          ],
        ),
      ),
    );

    if (value != null) {
      onSelectionChanged(value);
    }
  }

  Widget _buildOption(
    BuildContext context, {
    required bool isAnonymous,
    required String title,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, isAnonymous),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Row(
          children: [
            MyProfileImage(isAnnonymous: isAnonymous, size: 40),
            Gap(15.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFFD65A73),
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
