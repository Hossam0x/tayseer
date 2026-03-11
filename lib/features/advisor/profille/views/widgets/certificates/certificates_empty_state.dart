import 'package:tayseer/my_import.dart';

class CertificatesEmptyState extends StatelessWidget {
  const CertificatesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.emptyBoxImage, width: 150.w),
            Gap(16.h),
            Text(
              context.tr('no_certificates_yet'),
              style: Styles.textStyle16Meduim.copyWith(
                color: AppColors.kGreyB3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
