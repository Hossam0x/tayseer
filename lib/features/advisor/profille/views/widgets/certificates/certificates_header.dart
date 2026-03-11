
import 'package:tayseer/features/advisor/profille/views/widgets/certificates/certificate_item_card.dart';
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
          style: Styles.textStyle18Bold.copyWith(
            color: AppColors.secondary800,
          ),
        ),
        TextButton.icon(
          onPressed: () => navigateToAddCertificate(context, advisorId),
          label: Text(
            context.tr('add'),
            style: Styles.textStyle16Meduim.copyWith(
              color: AppColors.secondary400,
            ),
          ),
          icon: Icon(
            Icons.add,
            size: 22.w,
            color: AppColors.secondary400,
          ),
        ),
      ],
    );
  }
}
