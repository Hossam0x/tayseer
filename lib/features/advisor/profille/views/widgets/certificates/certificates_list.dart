
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificate_item_card.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificates_empty_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/profille/data/models/certificate_model.dart';

class CertificatesList extends StatelessWidget {
  final List<CertificateModel> certificates;
  final bool isMe;
  final String advisorId;

  const CertificatesList({
    super.key,
    required this.certificates,
    required this.isMe,
    required this.advisorId,
  });

  @override
  Widget build(BuildContext context) {
    if (certificates.isEmpty) {
      return const CertificatesEmptyState();
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: certificates.length,
      itemBuilder: (_, index) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: CertificateItemCard(
          certificate: certificates[index],
          isMe: isMe,
          advisorId: advisorId,
        ),
      ),
    );
  }
}
