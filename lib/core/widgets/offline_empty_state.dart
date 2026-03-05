import 'package:tayseer/core/utils/app_strings.dart';
import 'package:tayseer/my_import.dart';

/// شاشة فارغة ودودة عند عدم وجود إنترنت وبدون كاش
class OfflineEmptyState extends StatelessWidget {
  const OfflineEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AssetsData.noInternet, width: 150.w, height: 150.h),

              SizedBox(height: 24.h),
              Text(
                context.tr(AppStrings.offlineNoConnection),
                style: Styles.textStyle16.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                context.tr(AppStrings.offlineConnectToView),
                style: Styles.textStyle14.copyWith(color: Colors.grey.shade400),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
