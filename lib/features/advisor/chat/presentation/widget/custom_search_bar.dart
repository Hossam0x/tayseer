import 'package:tayseer/my_import.dart';

class CustomSearchBar extends StatelessWidget {
  final bool isReadOnly; // ده المتغير اللي هيحدد الحالة
  final VoidCallback? onTap; // ده الأكشن اللي هيحصل لما يكون للقراءة فقط
  final TextEditingController? controller; // عشان لو عايزة تكتبي وتسحبي الداتا

  const CustomSearchBar({
    super.key,
    this.isReadOnly = false, // الديفولت إنه للكتابة
    this.onTap,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      width: double.infinity,
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        onTap: () {
          if (isReadOnly && onTap != null) {
            onTap!();
          }
        },
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث عن ما تريده',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 20.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
