import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class AddCertificateActionButton extends StatelessWidget {
  const AddCertificateActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCertificateCubit, AddCertificateState>(
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      builder: (context, state) {
        final cubit = context.read<AddCertificateCubit>();
        return CustomBotton(
          height: 54.h,
          width: context.width * 0.8,
          title: state.isLoading
              ? context.tr('adding_certificate')
              : context.tr('add'),
          useGradient: true,
          onPressed: state.isLoading ? null : () => cubit.addCertificate(),
        );
      },
    );
  }
}
