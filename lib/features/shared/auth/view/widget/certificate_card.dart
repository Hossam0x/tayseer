import 'dart:io';

import 'package:tayseer/features/shared/auth/model/certificate_model.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/my_import.dart';

class CertificateCard extends StatelessWidget {
  final CertificateModel certificate;

  const CertificateCard({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: context.width * 0.32,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.kLightBlueColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.kBlueColor.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(certificate.image.path),
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                certificate.name,
                style: Styles.textStyle12,
                textAlign: TextAlign.center,
              ),
              Text(
                certificate.institution,
                style: Styles.textStyle10,
                textAlign: TextAlign.center,
              ),
              Text(certificate.year.year.toString(), style: Styles.textStyle10),
            ],
          ),
        ),

        /// ❌ Remove Button
        Positioned(
          top: 5,
          right: 5,
          child: InkWell(
            onTap: () {
              authCubit.removeCertificate(certificate);
            },
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(Icons.close, size: 16, color: AppColors.kRedColor),
            ),
          ),
        ),
      ],
    );
  }
}
