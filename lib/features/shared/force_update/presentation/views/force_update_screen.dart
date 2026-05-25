import 'package:tayseer/my_import.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة الـ Force Update — تغطي كل الشاشة ولا يمكن تجاوزها
class ForceUpdateScreen extends StatelessWidget {
  final String storeUrl;

  const ForceUpdateScreen({super.key, required this.storeUrl});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // منع الـ back button من إغلاق الشاشة
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // أيقونة التطبيق
                  Container(
                    width: 110.w,
                    height: 110.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28.r),
                      child: Image.asset(
                        AssetsData.kAppLogotayseerImage,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // أيقونة التحديث
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.system_update_rounded,
                      color: Colors.white,
                      size: 32.sp,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // العنوان
                  Text(
                    context.tr(AppStrings.forceUpdateTitle),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontFamily: 'ibmp',
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // الوصف
                  Text(
                    context.tr(AppStrings.forceUpdateDescription),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.6,
                      fontFamily: 'ibmp',
                    ),
                  ),

                  const Spacer(flex: 2),

                  // زر التحديث
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () => _openStore(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.kprimaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Platform.isIOS
                                ? Icons.apple_rounded
                                : Icons.shop_rounded,
                            size: 22.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            Platform.isIOS
                                ? context.tr(
                                    AppStrings.forceUpdateButtonAppStore,
                                  )
                                : context.tr(
                                    AppStrings.forceUpdateButtonGooglePlay,
                                  ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'ibmp',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
