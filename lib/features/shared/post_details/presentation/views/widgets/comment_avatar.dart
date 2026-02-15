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

    return PopupMenuButton<bool>(
      offset: Offset(0, -130.h),
      onSelected: onSelectionChanged,
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      elevation: 6,
      constraints: BoxConstraints(minWidth: 180.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: false,
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              const MyProfileImage(isAnnonymous: false, size: 36),
              Gap(12.w),
              Text(
                kCurrentUserData?.name ?? "عام ",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: true,
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            children: [
              const MyProfileImage(isAnnonymous: true, size: 36),
              Gap(12.w),
              Text(
                context.tr(AppStrings.anonymous),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
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
}
