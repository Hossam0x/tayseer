import 'package:tayseer/features/advisor/settings/view/widgets/advisor_terms/commission_banner.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/advisor_terms/term_item.dart';
import 'package:tayseer/my_import.dart';

class TermsContent extends StatelessWidget {
  final double appInterestPercentage;
  final String subscriptionType;
  final bool isLoading;

  const TermsContent({
    super.key,
    required this.appInterestPercentage,
    required this.subscriptionType,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final bool canReduce =
        subscriptionType == 'gold' || subscriptionType == 'ultra';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommissionBanner(
            percentage: appInterestPercentage,
            canReduce: canReduce,
            isLoading: isLoading,
          ),
          Gap(20.h),
          TermItem(
            number: '١',
            title: context.tr('terms_commission_title'),
            body: context.tr('terms_commission_body'),
            icon: Icons.percent_rounded,
            iconColor: AppColors.kprimaryColor,
          ),
          TermItem(
            number: '٢',
            title: context.tr('terms_delay_title'),
            body: context.tr('terms_delay_body'),
            icon: Icons.timer_off_outlined,
            iconColor: Colors.orange,
          ),
          TermItem(
            number: '٣',
            title: context.tr('terms_manipulation_title'),
            body: context.tr('terms_manipulation_body'),
            icon: Icons.gavel_rounded,
            iconColor: Colors.red.shade600,
          ),
          TermItem(
            number: '٤',
            title: context.tr('terms_signature_title'),
            body: context.tr('terms_signature_body'),
            icon: Icons.draw_outlined,
            iconColor: Colors.purple,
          ),
          TermItem(
            number: '٥',
            title: context.tr('terms_privacy_title'),
            body: context.tr('terms_privacy_body'),
            icon: Icons.shield_outlined,
            iconColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
