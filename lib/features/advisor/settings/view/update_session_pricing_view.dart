import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/update_add_sessions_body.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/update_offerings_summary_body.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/update_select_country_body.dart';
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
          // loading state
          if (state.isLoading) {
            return Scaffold(
              body: CustomBackground(
                child: const SafeArea(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }
          return Scaffold(
            body: CustomBackground(
              child: SafeArea(child: _buildStep(state.step)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep(UpdateOfferingsStep step) {
    switch (step) {
      case UpdateOfferingsStep.selectCountry:
        return const UpdateSelectCountryBody();
      case UpdateOfferingsStep.addSessions:
        return const UpdateAddSessionsBody();
      case UpdateOfferingsStep.summary:
        return const UpdateOfferingsSummaryBody();
    }
  }
}
