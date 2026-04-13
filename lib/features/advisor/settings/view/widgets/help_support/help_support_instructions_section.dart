import 'package:tayseer/my_import.dart';

class HelpSupportInstructionsSection extends StatelessWidget {
  const HelpSupportInstructionsSection({super.key});

  static const List<_StepItem> _steps = [
    _StepItem(key: 'login_step', icon: Icons.person_outline_rounded),
    _StepItem(key: 'booking_step', icon: Icons.calendar_today_outlined),
    _StepItem(key: 'payment_step', icon: Icons.payment_outlined),
    _StepItem(key: 'access_step', icon: Icons.video_call_outlined),
    _StepItem(key: 'support_step', icon: Icons.headset_mic_outlined),
  ];

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
              children: _steps.map((step) => _StepRow(step: step)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final _StepItem step;
  const _StepRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(step.icon, size: 20.w, color: AppColors.kprimaryColor),
          Gap(10.w),
          Expanded(
            child: Text(
              context.tr(step.key),
              style: Styles.textStyle14.copyWith(
                color: AppColors.secondary600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem {
  final String key;
  final IconData icon;
  const _StepItem({required this.key, required this.icon});
}
