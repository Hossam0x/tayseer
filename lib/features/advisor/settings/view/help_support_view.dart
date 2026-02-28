import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/help_support_cubit.dart';
import 'package:tayseer/my_import.dart';

class HelpSupportView extends StatelessWidget {
  const HelpSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HelpSupportCubit>(),
      child: const _HelpSupportContent(),
    );
  }
}

class _HelpSupportContent extends StatefulWidget {
  const _HelpSupportContent();

  @override
  State<_HelpSupportContent> createState() => _HelpSupportContentState();
}

class _HelpSupportContentState extends State<_HelpSupportContent> {
  final TextEditingController _problemController = TextEditingController();

  final List<String> faqs = [
    'ما هو تطبيق تيسير',
    'كيف أحجز جلسة',
    'طرق الدفع المتاحة',
    'كيفية إلغاء الحجز',
  ];

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 110.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    Gap(16.h),
                    SimpleAppBar(
                      title: context.tr('help_and_support'),
                      isLargeTitle: true,
                    ),
                    Gap(36.h),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildFaqs(),
                          Gap(24.h),
                          _buildInstructions(),
                          Gap(24.h),
                          _buildReportProblem(),
                          Gap(24.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child:
                                BlocConsumer<
                                  HelpSupportCubit,
                                  HelpSupportState
                                >(
                                  listener: (context, state) {
                                    if (state.isSuccess) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        CustomSnackBar(
                                          context,
                                          text: context.tr(
                                            'problem_sent_success',
                                          ),
                                          isSuccess: true,
                                        ),
                                      );
                                      _problemController.clear();
                                    } else if (state.errorMessage != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        CustomSnackBar(
                                          context,
                                          text: state.errorMessage!,
                                          isSuccess: false,
                                        ),
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    return CustomBotton(
                                      height: 54.h,
                                      width: double.infinity,
                                      title: state.isSending
                                          ? context.tr('sending')
                                          : context.tr('send'),
                                      useGradient: true,
                                      onPressed: state.isSending
                                          ? null
                                          : () {
                                              context
                                                  .read<HelpSupportCubit>()
                                                  .sendProblem(
                                                    _problemController.text,
                                                  );
                                            },
                                    );
                                  },
                                ),
                          ),
                          Gap(40.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqs() {
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
              Column(
                children: faqs.asMap().entries.map((entry) {
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
                      key: ValueKey(index), // Ensure uniqueness
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
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructions() {
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

  Widget _buildReportProblem() {
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
            controller: _problemController,
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
