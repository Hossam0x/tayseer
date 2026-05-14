import 'package:tayseer/my_import.dart';

class BookingSuccessView extends StatelessWidget {
  const BookingSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => context.pushNamedAndRemoveUntil(
                      predicate: (route) => true,
                      AppRouter.kUserLayoutView,
                    ),
                    icon: Icon(
                      Icons.close,
                      color: const Color(0xFF530D1D),
                      size: 30.sp,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  "تم حجز الاستشارة بنجاح",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kprimaryTextColor,
                    fontFamily: 'Arial',
                  ),
                ),
                const Spacer(),
                Image.asset(
                  AssetsData.ratingSuccessIcon,
                  width: 250.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20.h),
                Text(
                  ". شكراً لك سيتم مراجعته والنظر فيه",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 2),
                // ── زر عرض جلساتي ──────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // امسح الـ stack وروح للـ layout ثم افتح صفحة الجلسات
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.kUserLayoutView,
                        (route) => false,
                      );
                      Navigator.of(
                        context,
                      ).pushNamed(AppRouter.kUserSessionsView);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kprimaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "عرض جلساتي",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // ── زر الرجوع للرئيسية ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.pushNamedAndRemoveUntil(
                      predicate: (route) => true,
                      AppRouter.kUserLayoutView,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.kprimaryColor,
                      side: BorderSide(color: AppColors.kprimaryColor),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "الرئيسية",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
