import 'package:tayseer/features/shared/profile/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/features/shared/profile/data/models/certificate_model.dart';
import 'package:tayseer/my_import.dart';

class CertificatesHeader extends StatelessWidget {
  final String advisorId;

  const CertificatesHeader({super.key, required this.advisorId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          context.tr('certificates'),
          style: Styles.textStyle18Bold.copyWith(color: AppColors.secondary800),
        ),
        TextButton.icon(
          onPressed: () => _navigateToAdd(context),
          label: Text(
            context.tr('add'),
            style: Styles.textStyle16Meduim.copyWith(
              color: AppColors.secondary400,
            ),
          ),
          icon: Icon(Icons.add, size: 22.w, color: AppColors.secondary400),
        ),
      ],
    );
  }

  void _navigateToAdd(BuildContext context) {
    final cubit = context.read<CertificatesCubit>();
    Navigator.pushNamed(context, AppRouter.kAddCertificateView).then((result) {
      if (!context.mounted) return;
      if (result is CertificateModel) {
        cubit.addCertificate(result);
      } else if (result == true) {
        cubit.refresh(advisorId: advisorId);
      }
    });
  }
}
