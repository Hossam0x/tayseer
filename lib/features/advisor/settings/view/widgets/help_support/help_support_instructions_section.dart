import 'package:tayseer/my_import.dart';

class HelpSupportInstructionsSection extends StatelessWidget {
  const HelpSupportInstructionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('app_instructions'),
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          Gap(16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.kWhiteColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InstructionItem(text: context.tr('login_step')),
                _InstructionItem(text: context.tr('booking_step')),
                _InstructionItem(text: context.tr('payment_step')),
                _InstructionItem(text: context.tr('access_step')),
                _InstructionItem(text: context.tr('support_step')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final String text;
  const _InstructionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
      ),
    );
  }
}
