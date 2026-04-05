import 'package:tayseer/core/widgets/certificate_date_picker.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateDatePicker extends StatelessWidget {
  const EditCertificateDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditCertificateCubit, EditCertificateState>(
      buildWhen: (previous, current) => previous.date != current.date,
      builder: (context, state) {
        return CertificateDatePicker(
          date: state.date,
          hintKey: 'choose_date',
          onDatePicked: context.read<EditCertificateCubit>().updateDate,
        );
      },
    );
  }
}
