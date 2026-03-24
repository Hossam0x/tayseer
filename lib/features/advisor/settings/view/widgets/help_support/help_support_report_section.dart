import 'package:tayseer/my_import.dart';

class HelpSupportReportSection extends StatelessWidget {
  final TextEditingController controller;
  const HelpSupportReportSection({super.key, required this.controller});

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
            context.tr('report_problem'),
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          Gap(12.h),
          Text(
            context.tr('report_problem_subtitle'),
            style: Styles.textStyle14,
          ),
          Gap(12.h),
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.tr('problem_details_hint'),
              hintStyle: Styles.textStyle14.copyWith(color: AppColors.hintText),
              filled: true,
              fillColor: AppColors.secondary950,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
