import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateActionButton extends StatelessWidget {
  const EditCertificateActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditCertificateCubit, EditCertificateState>(
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      builder: (context, state) {
        final cubit = context.read<EditCertificateCubit>();
        return CustomBotton(
          height: 54.h,
          width: context.width * 0.8,
          useGradient: true,
          title: state.isLoading
              ? context.tr('updating')
              : context.tr('update'),
          onPressed: state.isLoading
              ? null
              : () => cubit.updateCertificate(),
        );
      },
    );
  }
}
