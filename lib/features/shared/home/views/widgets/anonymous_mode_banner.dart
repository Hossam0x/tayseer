import 'package:flutter/cupertino.dart';
import 'package:tayseer/my_import.dart'; // تأكد أن هذا الملف يحتوي على isUserAnonymous

class AnonymousModeBanner extends StatefulWidget {
  const AnonymousModeBanner({super.key});

  @override
  State<AnonymousModeBanner> createState() => _AnonymousModeBannerState();
}

class _AnonymousModeBannerState extends State<AnonymousModeBanner> {
  bool _isVisible = true;

  late bool _isAnonymous;

  @override
  void initState() {
    super.initState();
    // ✅ بنأخد القيمة الابتدائية من المتغير العام (Global Variable)
    _isAnonymous = isUserAnonymous;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ لو اليوزر قفل البانر، نرجع ويدجت فاضية
    if (!_isVisible) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 8.h,
          bottom: 16.h,
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 69, 106, 0.17),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    // ✅ لوجيك الإغلاق الداخلي
                    onTap: () {
                      setState(() {
                        _isVisible = false;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      size: 20.sp,
                      color: AppColors.secondary400,
                    ),
                  ),
                  Gap(5.h),
                  Text(
                    "هل تريد التعامل كمجهول الهوية ؟",
                    style: Styles.textStyle14Bold.copyWith(
                      color: AppColors.secondary800,
                    ),
                  ),
                  Gap(9.h),
                  Text(
                    "في حالة تفعيدك للميزة تقدر تتفاعل وتعلق بدون معرفة بياناتك",
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                ],
              ),
            ),

            Gap(10.w),
            Transform.scale(
              scaleX: -0.9,
              scaleY: 0.9,
              child: CupertinoSwitch(
                value: _isAnonymous,
                activeColor: const Color(0xFFF06C88),
                trackColor: Colors.grey.shade300,
                onChanged: (value) {
                  setState(() {
                    _isAnonymous = value;
                  });

                  // ✅ تحديث المتغير العام (Global Variable) مباشرة
                  // isUserAnonymous = value;
                  // print("Global isUserAnonymous Updated to: $isUserAnonymous");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
