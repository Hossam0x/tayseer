import 'package:tayseer/features/shared/profile/cubit/certificates/certificates_cubit.dart';
import 'package:tayseer/my_import.dart';

class CertificatesErrorSection extends StatelessWidget {
  final String advisorId;

  const CertificatesErrorSection({super.key, required this.advisorId});

  @override
  Widget build(BuildContext context) {
    final state = context.read<CertificatesCubit>().state;
    return CustomErrorView(
      message: state.errorMessage,
      onRetry: () =>
          context.read<CertificatesCubit>().refresh(advisorId: advisorId),
    );
  }
}
