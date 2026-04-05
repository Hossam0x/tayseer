import 'package:intl/intl.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/shared/profile/data/models/certificate_model.dart';
import 'package:tayseer/features/shared/profile/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/my_import.dart';

class CertificateItemCard extends StatelessWidget {
  final CertificateModel certificate;
  final bool isMe;
  final String advisorId;

  const CertificateItemCard({
    super.key,
    required this.certificate,
    required this.isMe,
    required this.advisorId,
  });

  @override
  Widget build(BuildContext context) {
    if (certificate.nameCertificate.isEmpty) return const SizedBox.shrink();

    final heroTag = 'certificate_image_${certificate.id}';

    return GestureDetector(
      onTap: () => isMe ? _navigateToEdit(context) : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary100),
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.whiteCardBack,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CertificateImage(imageUrl: certificate.image, heroTag: heroTag),
            SizedBox(width: 16.w),
            Expanded(child: _CertificateDetails(certificate: certificate)),
            if (isMe) AppImage(AssetsData.editIcon, width: 20.w),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    final cubit = context.read<CertificatesCubit>();
    Navigator.pushNamed(
      context,
      AppRouter.kEditCertificateView,
      arguments: {
        'certificatesCubit': cubit,
        'certificates': cubit.state.certificates,
        'selectedCertificate': certificate,
      },
    ).then((result) {
      if (!context.mounted) return;
      if (result is CertificateModel) {
        cubit.updateCertificateLocally(result);
      }
    });
  }
}

class _CertificateImage extends StatelessWidget {
  final String? imageUrl;
  final String heroTag;

  const _CertificateImage({required this.imageUrl, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: hasImage
          ? () => FullScreenImageView.show(
              context,
              imageUrl: imageUrl,
              heroTag: heroTag,
            )
          : null,
      child: Hero(
        tag: heroTag,
        child: Container(
          width: 110.w,
          height: 90.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: Colors.grey.shade100,
          ),
          child: hasImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.school,
                      color: Colors.grey.shade400,
                      size: 22.w,
                    ),
                  ),
                )
              : Icon(Icons.school, color: Colors.grey.shade400, size: 22.w),
        ),
      ),
    );
  }
}

class _CertificateDetails extends StatelessWidget {
  final CertificateModel certificate;

  const _CertificateDetails({required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          certificate.nameCertificate,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          certificate.fromWhere,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          DateFormat('yyyy').format(certificate.date),
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
