import 'package:intl/intl.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/shared/profile/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/views/add_certificate_view.dart';
import 'package:tayseer/features/shared/profile/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/edit_certificate_view.dart';
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

    // Unique hero tag per certificate so animations don't clash
    final heroTag = 'certificate_image_${certificate.id}';

    return GestureDetector(
      onTap: () =>
          isMe ? _navigateToEditCertificate(context, certificate) : null,
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

  void _navigateToEditCertificate(
    BuildContext context,
    CertificateModel selectedCertificate,
  ) {
    final certificatesCubit = context.read<CertificatesCubit>();

    Navigator.push(
      context,
      PageRouteBuilder(
        settings: const RouteSettings(name: AppRouter.kEditCertificateView),
        pageBuilder: (context, animation, secondaryAnimation) {
          return BlocProvider.value(
            value: certificatesCubit,
            child: EditCertificateView(
              certificates: certificatesCubit.state.certificates,
              selectedCertificate: selectedCertificate,
            ),
          );
        },
        transitionsBuilder: _slideTransition,
      ),
    ).then((result) {
      if (result != null && result is CertificateModel) {
        certificatesCubit.updateCertificateLocally(result);
        // Removed refresh call to avoid full refetch
      } else if (result != null && result is Map && result['updated'] == true) {
        if (result['certificate'] != null) {
          certificatesCubit.updateCertificateLocally(result['certificate']);
        }
        // certificatesCubit.refresh(advisorId: advisorId); // Avoid refreshing if possible
      }
    });
  }

  Widget _slideTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;
    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    return SlideTransition(position: animation.drive(tween), child: child);
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
                    errorBuilder: (context, error, stackTrace) => Icon(
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

/// Navigate to add certificate view with slide transition.
void navigateToAddCertificate(BuildContext context, String advisorId) {
  Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const AddCertificateView(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  ).then((result) {
    if (result != null && result is CertificateModel && context.mounted) {
      context.read<CertificatesCubit>().addCertificate(result);
    } else if (result == true && context.mounted) {
      context.read<CertificatesCubit>().refresh(advisorId: advisorId);
    }
  });
}
