import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/update_add_sessions_body.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/update_offerings_summary_body.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/update_select_country_body.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/update_offerings_skeleton.dart';
import 'package:tayseer/my_import.dart';

class UpdateSessionPricingView extends StatelessWidget {
  const UpdateSessionPricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateOfferingsCubit>(
      create: (_) => getIt<UpdateOfferingsCubit>(),
      child: BlocConsumer<UpdateOfferingsCubit, UpdateOfferingsState>(
        listenWhen: (prev, curr) =>
            prev.saveState != curr.saveState ||
            prev.errorMessage != curr.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            showSafeSnackBar(
              context: context,
              text: context.tr(state.errorMessage!),
              isError: true,
            );
            context.read<UpdateOfferingsCubit>().clearError();
          }
          if (state.saveState == CubitStates.success) {
            showSafeSnackBar(
              context: context,
              text: context.tr('offerings_saved_successfully'),
              isSuccess: true,
            );
            context.read<UpdateOfferingsCubit>().clearSuccess();
            context.pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: AdvisorBackground(
              child: Stack(
                children: [
                  // Background image header — نفس باقي الـ settings
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 105.h,
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
                            title: context.tr('session_settings_title'),
                            onBack:
                                state.step == UpdateOfferingsStep.addSessions
                                ? () => context
                                      .read<UpdateOfferingsCubit>()
                                      .goBackToCountrySelection()
                                : state.step ==
                                          UpdateOfferingsStep.selectCountry &&
                                      state.hasSummaryData
                                ? () => context
                                      .read<UpdateOfferingsCubit>()
                                      .goBackToSummary()
                                : null,
                          ),
                          Gap(16.h),
                          // المحتوى حسب الـ step
                          Expanded(child: _buildStep(context, state)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(BuildContext context, UpdateOfferingsState state) {
    if (state.isLoading) {
      return const UpdateOfferingsSkeleton();
    }
    switch (state.step) {
      case UpdateOfferingsStep.selectCountry:
        return const UpdateSelectCountryBody();
      case UpdateOfferingsStep.addSessions:
        return const UpdateAddSessionsBody();
      case UpdateOfferingsStep.summary:
        return const UpdateOfferingsSummaryBody();
    }
  }
}
