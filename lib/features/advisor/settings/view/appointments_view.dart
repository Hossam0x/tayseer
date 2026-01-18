import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider_cubits.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/service_provider_states.dart';
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
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(context, text: state.errorMessage!, isError: true),
            );
            context.read<AppointmentsCubit>().clearError();
          }

          // // عرض رسالة النجاح فقط عند الانتهاء من الحفظ وبدون أخطاء
          // if (state.isSaving == false &&
          //     state.errorMessage == null &&
          //     !state.hasChanges) {
          //   Future.delayed(Duration.zero, () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       CustomSnackBar(
          //         context,
          //         text: 'تم حفظ التغييرات بنجاح',
          //         isSuccess: true,
          //       ),
          //     );
          //   });
          // }
        },
        builder: (context, state) {
          final cubit = context.read<AppointmentsCubit>();

          return Scaffold(
            body: AdvisorBackground(
              child: Stack(
                children: [
                  // الخلفية
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

                  // المحتوى
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          Gap(16.h),
                          SimpleAppBar(title: 'المواعيد'),
                          Gap(30.h),

                          // Loading State with Skeletonizer
                          if (state.state == CubitStates.loading)
                            Expanded(child: _buildSkeletonLoading())
                          // Error State
                          else if (state.state == CubitStates.failure)
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppColors.kRedColor,
                                      size: 48.w,
                                    ),
                                    Gap(16.h),
                                    Text(
                                      state.errorMessage ??
                                          'حدث خطأ في تحميل البيانات',
                                      textAlign: TextAlign.center,
                                      style: Styles.textStyle16.copyWith(
                                        color: AppColors.kRedColor,
                                      ),
                                    ),
                                    Gap(24.h),
                                    ElevatedButton(
                                      onPressed: () =>
                                          cubit.loadServiceProvider(),
                                      child: Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // Success State
                          else
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _buildTimeSlotsList(
                                      context,
                                      state,
                                      cubit,
                                    ),
                                  ),
                                  Gap(20.h),
                                  _buildSaveButton(context, cubit, state),
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

  Widget _buildSkeletonLoading() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: 7, // 7 أيام
        separatorBuilder: (context, index) => Gap(20.h),
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(16.w),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // اليوم والتبديل
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 80.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    Container(
                      width: 48.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
                Gap(16.h),

                // حقول الوقت
                Row(
                  children: [
                    Container(
                      width: 30.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Container(
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                    Gap(8.w),
                    Container(
                      width: 30.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(8.w),
                    Expanded(
                      child: Container(
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotsList(
    BuildContext context,
    AppointmentsState state,
    AppointmentsCubit cubit,
  ) {
    final weeklyAvailability = state.weeklyAvailability;

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      itemCount: weeklyAvailability.length,
      separatorBuilder: (context, index) => Gap(20.h),
      itemBuilder: (context, index) {
        final day = weeklyAvailability[index];
        final timeSlot = day.timeSlots.isNotEmpty ? day.timeSlots.first : null;

        return TimeSlotItem(
          name: day.dayName,
          initialFrom: timeSlot?.start ?? '00:00',
          initialTo: timeSlot?.end ?? '00:00',
          initialStatus: day.isEnabled,
          onStatusChanged: (isActive) {
            cubit.toggleDayStatus(day.dayOfWeek, isActive);
          },
          onTimeChanged: (start, end) {
            cubit.updateDayTimeSlot(day.dayOfWeek, start, end);
          },
        );
      },
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AppointmentsCubit cubit,
    AppointmentsState state,
  ) {
    return CustomBotton(
      height: 54.h,
      width: double.infinity,
      useGradient: true,
      title: state.isSaving
          ? 'جاري الحفظ...'
          : state.hasChanges
          ? 'حفظ التغييرات'
          : 'لا توجد تغييرات',
      onPressed: state.isSaving || !state.hasChanges
          ? null
          : () => cubit.saveChanges(context),
      backGroundcolor: state.hasChanges ? null : AppColors.inactiveColor,
    );
  }
}
