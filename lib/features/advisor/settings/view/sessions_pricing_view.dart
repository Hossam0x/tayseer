import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider/service_provider_cubits.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider/service_provider_states.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/session_pricing/session_pricing_skeleton.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/session_price_item.dart';
import 'package:tayseer/my_import.dart';

class SessionPricingView extends StatelessWidget {
  const SessionPricingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionPricingCubit>(
      create: (_) => getIt<SessionPricingCubit>(),
      child: BlocConsumer<SessionPricingCubit, SessionPricingState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            showSafeSnackBar(
              context: context,
              text: context.tr(state.errorMessage!),
              isError: true,
            );
            context.read<SessionPricingCubit>().clearError();
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            showSafeSnackBar(
              context: context,
              text: context.tr(state.successMessage!),
              isSuccess: true,
            );
            context.read<SessionPricingCubit>().clearSuccess();
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final cubit = context.read<SessionPricingCubit>();
          return Scaffold(
            body: AdvisorBackground(
              child: Stack(
                children: [
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
                            title: context.tr('session_pricing_title'),
                          ),
                          Gap(30.h),
                          if (state.state == CubitStates.loading)
                            const Expanded(child: SessionPricingSkeleton())
                          else if (state.state == CubitStates.failure)
                            CustomErrorView(
                              verticalPadding: 100,
                              message: state.errorMessage,
                              onRetry: () => cubit.loadServiceProvider(),
                            )
                          else
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _PricingList(
                                      state: state,
                                      cubit: cubit,
                                    ),
                                  ),
                                  Gap(20.h),
                                  _SaveButton(cubit: cubit, state: state),
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
        },
      ),
    );
  }
}

class _PricingList extends StatelessWidget {
  final SessionPricingState state;
  final SessionPricingCubit cubit;
  const _PricingList({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final sessionTypes = state.sessionTypes;
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: sessionTypes.length,
      separatorBuilder: (_, __) => Gap(20.h),
      itemBuilder: (_, index) {
        final sessionKey = sessionTypes.keys.elementAt(index);
        final session = sessionTypes[sessionKey]!;
        return SessionPriceItem(
          duration: session.durationText,
          initialPrice: session.price.toString(),
          initialStatus: session.isEnabled,
          onPriceChanged: (price) =>
              cubit.updateSessionPrice(sessionKey, int.tryParse(price) ?? 0),
          onStatusChanged: (isActive) =>
              cubit.toggleSessionStatus(sessionKey, isActive),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  final SessionPricingCubit cubit;
  final SessionPricingState state;
  const _SaveButton({required this.cubit, required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomBotton(
      height: 54.h,
      width: double.infinity,
      useGradient: true,
      title: state.isSaving
          ? context.tr('saving_status')
          : state.hasChanges
          ? context.tr('save_changes')
          : context.tr('no_changes'),
      onPressed: state.isSaving || !state.hasChanges
          ? null
          : () => cubit.saveChanges(),
      backGroundcolor: state.hasChanges ? null : AppColors.inactiveColor,
    );
  }
}
