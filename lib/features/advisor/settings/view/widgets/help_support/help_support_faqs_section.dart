import 'package:tayseer/features/advisor/settings/view/cubit/help_support/help_support_cubit.dart';
import 'package:tayseer/my_import.dart';

class HelpSupportFaqsSection extends StatelessWidget {
  const HelpSupportFaqsSection({super.key});

  static const List<String> _faqs = [
    'ما هو تطبيق تيسير',
    'كيف أحجز جلسة',
    'طرق الدفع المتاحة',
    'كيفية إلغاء الحجز',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HelpSupportCubit, HelpSupportState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsetsDirectional.only(
            start: 16.w,
            end: 16.w,
            top: 16.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.whiteCard2Back,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('faqs'),
                style: Styles.textStyle18Meduim.copyWith(
                  color: AppColors.primaryText,
                ),
              ),
              Gap(16.h),
              ..._faqs.asMap().entries.map((entry) {
                final index = entry.key;
                final question = entry.value;
                final isExpanded = state.expandedMap[index] ?? false;

                return Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    key: ValueKey(index),
                    initiallyExpanded: isExpanded,
                    onExpansionChanged: (expanded) {
                      context.read<HelpSupportCubit>().toggleExpansion(
                        index,
                        expanded,
                      );
                    },
                    title: Text(
                      question,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.blackColor,
                      ),
                    ),
                    trailing: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.dropDownArrow,
                        size: 24.w,
                      ),
                    ),
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    collapsedShape: const RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: 16.w,
                          left: 16.w,
                          bottom: 16.h,
                        ),
                        child: Text(
                          context.tr('faq_answer_placeholder'),
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
