import 'package:flutter/material.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final height = isMobile ? 36.0 : 39.0;
    final borderRadius = isMobile ? 25.0 : 30.0;
    final fontSize = isMobile ? 12.0 : 14.0;
    final contentPaddingH = isMobile ? 16.0 : 20.0;
    final contentPaddingV = isMobile ? 10.0 : 12.0;
    final iconSize = isMobile ? 18.0 : 20.0;

    return Container(
      height: height,
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
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: fontSize),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: iconSize),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: contentPaddingV,
            horizontal: contentPaddingH,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
