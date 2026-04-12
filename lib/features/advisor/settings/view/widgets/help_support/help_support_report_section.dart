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
          Row(
            children: [
              Icon(
                Icons.support_agent_outlined,
                color: AppColors.kprimaryColor,
                size: 22.w,
              ),
              Gap(8.w),
              Text(
                context.tr('report_problem'),
                style: Styles.textStyle18Meduim.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          Gap(8.h),
          Text(
            context.tr('report_problem_subtitle'),
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary600,
              height: 1.5,
            ),
          ),
          Gap(14.h),
          TextField(
            controller: controller,
            maxLines: 5,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: context.tr('problem_details_hint'),
              hintStyle: Styles.textStyle14.copyWith(color: AppColors.hintText),
              filled: true,
              fillColor: AppColors.secondary950,
              contentPadding: EdgeInsets.all(14.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppColors.kprimaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
