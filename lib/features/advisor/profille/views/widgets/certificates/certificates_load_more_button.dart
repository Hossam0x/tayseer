import 'package:tayseer/features/advisor/profille/views/cubit/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates_state.dart';
import 'package:tayseer/my_import.dart';

class CertificatesLoadMoreButton extends StatelessWidget {
  final CertificatesState state;

  const CertificatesLoadMoreButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
      child: state.isLoadingMore
          ? Center(
              child:
                  CircularProgressIndicator(color: AppColors.kprimaryColor),
            )
          : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    context.read<CertificatesCubit>().loadMore(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kWhiteColor,
                  foregroundColor: AppColors.kprimaryColor,
                  side: BorderSide(
                      color: AppColors.kprimaryColor, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  elevation: 0,
                ),
                child: Text(
                  context.tr('load_more_certificates'),
                  style: Styles.textStyle14Meduim.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
    );
  }
}
