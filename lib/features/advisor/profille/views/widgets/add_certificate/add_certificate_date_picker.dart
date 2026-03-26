import 'package:tayseer/core/widgets/certificate_date_picker.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/add_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/add_certificate_state.dart';
import 'package:tayseer/my_import.dart';

class AddCertificateDatePicker extends StatelessWidget {
  const AddCertificateDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddCertificateCubit, AddCertificateState>(
      buildWhen: (previous, current) => previous.date != current.date,
      builder: (context, state) {
        return CertificateDatePicker(
          date: state.date,
          hintKey: 'certificate_year_obtained',
          onDatePicked: context.read<AddCertificateCubit>().updateDate,
        );
      },
    );
  }
}
