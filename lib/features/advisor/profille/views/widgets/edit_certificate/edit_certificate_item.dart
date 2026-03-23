import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_cubit.dart';
import 'package:tayseer/my_import.dart';
import 'package:intl/intl.dart';

class EditCertificateItem extends StatelessWidget {
  final CertificateModel cert;
  final bool isSelected;

  const EditCertificateItem({super.key, required this.cert, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditCertificateCubit>();
    return GestureDetector(
      onTap: () => cubit.selectCertificate(cert),
      child: Container(
        width: 120.w,
        margin: EdgeInsets.only(left: 7.w),
        decoration: BoxDecoration(
          color: AppColors.mainColor.withOpacity(0.1),
          border: Border.all(
            color: isSelected ? AppColors.primary300 : AppColors.mainColor,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 14.r,
                  right: 14.r,
                  top: 14.r,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    children: [
                      cert.image != null
                          ? CachedNetworkImage(
                              imageUrl: cert.image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              placeholder: (context, url) => _buildPlaceholder(),
                              errorWidget: (context, url, error) =>
                                  _buildErrorWidget(),
                            )
                          : _buildDefaultImage(),
                      Positioned(
                        top: 4.r,
                        left: 4.r,
                        child: AppImage(
                          AssetsData.editIcon,
                          width: 20.w,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildCertDetails(cert),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: Shimmer.fromColors(
        baseColor: AppColors.kprimaryColor,
        highlightColor: AppColors.kprimaryColor.withOpacity(0.5),
        child: Container(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.school, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildCertDetails(CertificateModel cert) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          Text(
            cert.nameCertificate,
            style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          Text(
            cert.fromWhere,
            style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          Text(
            DateFormat('yyyy').format(cert.date),
            style: Styles.textStyle16.copyWith(color: AppColors.primaryText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
