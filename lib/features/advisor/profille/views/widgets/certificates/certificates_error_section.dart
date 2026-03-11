import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/my_import.dart';

class CertificatesErrorSection extends StatelessWidget {
  final String advisorId;

  const CertificatesErrorSection({super.key, required this.advisorId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 100.h),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            context.tr('error'),
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
          ),
          Gap(24.h),
          ElevatedButton(
            onPressed: () => context
                .read<CertificatesCubit>()
                .refresh(advisorId: advisorId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              context.tr('retry'),
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
