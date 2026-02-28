import 'package:tayseer/my_import.dart';

Widget buildIconTag(String text) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: const Color(0xFFeae4e8),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Text(text, style: Styles.textStyle12),
  );
}
