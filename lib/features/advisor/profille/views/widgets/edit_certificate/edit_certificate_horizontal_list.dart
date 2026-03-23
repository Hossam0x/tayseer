import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/certificates/edit_certificate_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/edit_certificate/edit_certificate_item.dart';
import 'package:tayseer/my_import.dart';

class EditCertificateHorizontalList extends StatelessWidget {
  final List<CertificateModel> certificates;

  const EditCertificateHorizontalList({super.key, required this.certificates});

  @override
  Widget build(BuildContext context) {
    if (certificates.isEmpty) return const SizedBox.shrink();

    return BlocBuilder<EditCertificateCubit, EditCertificateState>(
      buildWhen: (previous, current) =>
          previous.selectedCertificateId != current.selectedCertificateId,
      builder: (context, state) {
        return SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              final cert = certificates[index];
              final isSelected = state.selectedCertificateId == cert.id;

              return EditCertificateItem(
                cert: cert,
                isSelected: isSelected,
              );
            },
          ),
        );
      },
    );
  }
}
