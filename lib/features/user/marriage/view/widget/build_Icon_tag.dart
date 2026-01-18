import 'package:tayseer/my_import.dart';

Widget buildIconTag(String text, String icon) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: const Color(0xFFeae4e8),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppImage(icon, gradientColorSvg: AppColors.linearGradientIcon),
        Gap(5.w),
        Text(text, style: Styles.textStyle12),
      ],
    ),
  );
}
