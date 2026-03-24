import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/help_support/help_support_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/help_support/help_support_faqs_section.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/help_support/help_support_instructions_section.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/help_support/help_support_report_section.dart';
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
                          const HelpSupportFaqsSection(),
                          Gap(24.h),
                          const HelpSupportInstructionsSection(),
                          Gap(24.h),
                          HelpSupportReportSection(
                            controller: _problemController,
                          ),
                          Gap(24.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: _SendButton(controller: _problemController),
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
}

class _SendButton extends StatelessWidget {
  final TextEditingController controller;
  const _SendButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HelpSupportCubit, HelpSupportState>(
      listener: (context, state) {
        if (state.isSuccess) {
          AppToast.success(context, context.tr('problem_sent_success'));
          controller.clear();
          Navigator.pop(context);
        } else if (state.errorMessage != null) {
          AppToast.error(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return CustomBotton(
          height: 54.h,
          width: double.infinity,
          title: state.isSending ? context.tr('sending') : context.tr('send'),
          useGradient: true,
          onPressed: state.isSending
              ? null
              : () => context.read<HelpSupportCubit>().sendProblem(
                  controller.text,
                ),
        );
      },
    );
  }
}
