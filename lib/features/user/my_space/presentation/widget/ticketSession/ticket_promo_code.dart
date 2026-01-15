import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/my_import.dart';

class TicketPromoCode extends StatefulWidget {
  const TicketPromoCode({super.key});

  @override
  State<TicketPromoCode> createState() => _TicketPromoCodeState();
}

class _TicketPromoCodeState extends State<TicketPromoCode> {
  bool isApplied = false;
  bool hasText = false;

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const primaryPink = Color(0xFFD3556E);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          AppImage(
            AssetsData.cuponCodeIcon,
            color: hasText || isApplied ? primaryPink : Colors.grey.shade400,
            width: 20.sp,
          ),
          SizedBox(width: 10.w),

          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !isApplied,
              onChanged: (value) {
                setState(() {
                  hasText = value.trim().isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: "أدخل كود الخصم",
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),

          TextButton(
            onPressed: () {
              if (isApplied) {
                setState(() {
                  isApplied = false;
                  hasText = false;
                  _controller.clear();
                });
              } else {
                if (hasText) {
                  setState(() {
                    isApplied = true;
                  });
                }
              }
            },
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(
                (!isApplied && !hasText) ? Colors.transparent : null,
              ),
            ),
            child: Text(
              isApplied ? "إزالة" : "تطبيق",
              style: TextStyle(
                color: isApplied
                    ? Colors.red
                    : (hasText ? primaryPink : Colors.grey.shade400),
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
