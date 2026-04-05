import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider/service_provider_cubits.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider/service_provider_states.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/appointments/appointments_skeleton.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/time_slot_item.dart';
import 'package:tayseer/my_import.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppointmentsCubit>(
      create: (_) => getIt<AppointmentsCubit>(),
      child: BlocConsumer<AppointmentsCubit, AppointmentsState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            showSafeSnackBar(
              context: context,
              text: context.tr(state.errorMessage!),
              isError: true,
            );
            context.read<AppointmentsCubit>().clearError();
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            showSafeSnackBar(
              context: context,
              text: context.tr(state.successMessage!),
              isSuccess: true,
            );
            context.read<AppointmentsCubit>().clearSuccess();
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) Navigator.pop(context);
            });
          }
        },
        builder: (context, state) {
          final cubit = context.read<AppointmentsCubit>();
          return Scaffold(
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
                          SimpleAppBar(title: context.tr('appointments_title')),
                          Gap(30.h),
                          if (state.state == CubitStates.loading)
                            const Expanded(child: AppointmentsSkeleton())
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
                                    child: _TimeSlotsList(
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

class _TimeSlotsList extends StatelessWidget {
  final AppointmentsState state;
  final AppointmentsCubit cubit;
  const _TimeSlotsList({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final days = state.weeklyAvailability;
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: days.length,
      separatorBuilder: (_, __) => Gap(20.h),
      itemBuilder: (_, index) {
        final day = days[index];
        final timeSlot = day.timeSlots.isNotEmpty ? day.timeSlots.first : null;
        return TimeSlotItem(
          name: day.dayName,
          initialFrom: timeSlot?.start ?? '00:00',
          initialTo: timeSlot?.end ?? '00:00',
          initialStatus: day.isEnabled,
          onStatusChanged: (isActive) {
            cubit.toggleDayStatus(day.dayOfWeek, isActive);
            if (isActive && (timeSlot == null || timeSlot.start == '00:00')) {
              cubit.updateDayTimeSlot(day.dayOfWeek, '09:00', '17:00');
            }
          },
          onTimeChanged: (start, end) =>
              cubit.updateDayTimeSlot(day.dayOfWeek, start, end),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  final AppointmentsCubit cubit;
  final AppointmentsState state;
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
      onPressed: state.isSaving || !state.hasChanges || !state.isValid
          ? null
          : () => cubit.saveChanges(),
      backGroundcolor: state.hasChanges && state.isValid
          ? null
          : AppColors.inactiveColor,
    );
  }
}
