import 'package:tayseer/features/settings/view/widgets/time_slot_item.dart';
import 'package:tayseer/my_import.dart';

class AppointmentsView extends StatelessWidget {
  const AppointmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120.h,
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
                    _buildHeader(context),
                    Gap(30.h),
                    Expanded(child: _buildTimeSlotsList()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back, color: AppColors.blackColor),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            'المواعيد',
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildTimeSlotsList() {
    final timeSlots = [
      {'name': 'السبت', 'from': '09:00', 'to': '09:00', 'isActive': false},
      {'name': 'الأحد', 'from': '09:00', 'to': '09:00', 'isActive': true},
      {'name': 'الاثنين', 'from': '09:00', 'to': '09:00', 'isActive': false},
      {'name': 'الثلاثاء', 'from': '09:00', 'to': '09:00', 'isActive': true},
      {'name': 'الأربعاء', 'from': '09:00', 'to': '09:00', 'isActive': true},
      {'name': 'الخميس', 'from': '09:00', 'to': '09:00', 'isActive': false},
      {'name': 'الجمعة', 'from': '09:00', 'to': '09:00', 'isActive': false},
    ];

    return ListView.separated(
      itemCount: timeSlots.length,
      separatorBuilder: (context, index) => Gap(20.h),
      itemBuilder: (context, index) {
        return TimeSlotItem(
          name: timeSlots[index]['name'] as String,
          initialFrom: timeSlots[index]['from'] as String,
          initialTo: timeSlots[index]['to'] as String,
          initialStatus: timeSlots[index]['isActive'] as bool,
        );
      },
    );
  }
}

// import 'package:tayseer/features/settings/view/cubit/service_provider_cubits.dart';
// import 'package:tayseer/features/settings/view/cubit/service_provider_states.dart';
// import 'package:tayseer/features/settings/view/widgets/time_slot_item.dart';
// import 'package:tayseer/my_import.dart';

// class AppointmentsView extends StatelessWidget {
//   const AppointmentsView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<AppointmentsCubit>(
//       create: (_) => getIt<AppointmentsCubit>(),
//       child: BlocConsumer<AppointmentsCubit, AppointmentsState>(
//         listener: (context, state) {
//           if (state.errorMessage != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               CustomSnackBar(context, text: state.errorMessage!, isError: true),
//             );
//             context.read<AppointmentsCubit>().clearError();
//           }

//           if (state.isSaving == false && state.errorMessage == null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               CustomSnackBar(
//                 context,
//                 text: 'تم حفظ التغييرات بنجاح',
//                 isSuccess: true,
//               ),
//             );
//           }
//         },
//         builder: (context, state) {
//           final cubit = context.read<AppointmentsCubit>();

//           return Scaffold(
//             body: AdvisorBackground(
//               child: Stack(
//                 children: [
//                   Positioned(
//                     top: 0,
//                     left: 0,
//                     right: 0,
//                     height: 120.h,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           image: AssetImage(AssetsData.homeBarBackgroundImage),
//                           fit: BoxFit.fill,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SafeArea(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20.w),
//                       child: Column(
//                         children: [
//                           Gap(16.h),
//                           _buildHeader(context),
//                           Gap(30.h),
//                           if (state.state == CubitStates.loading)
//                             Expanded(
//                               child: Center(
//                                 child: CircularProgressIndicator(
//                                   color: AppColors.kprimaryColor,
//                                 ),
//                               ),
//                             )
//                           else if (state.state == CubitStates.failure)
//                             Expanded(
//                               child: Center(
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.error_outline,
//                                       color: AppColors.kRedColor,
//                                       size: 48.w,
//                                     ),
//                                     Gap(16.h),
//                                     Text(
//                                       state.errorMessage ??
//                                           'حدث خطأ في تحميل البيانات',
//                                       textAlign: TextAlign.center,
//                                     ),
//                                     Gap(24.h),
//                                     ElevatedButton(
//                                       onPressed: () =>
//                                           cubit.loadServiceProvider(),
//                                       child: Text('إعادة المحاولة'),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             )
//                           else
//                             Expanded(
//                               child: Column(
//                                 children: [
//                                   Expanded(
//                                     child: _buildTimeSlotsList(
//                                       context,
//                                       state,
//                                       cubit,
//                                     ),
//                                   ),
//                                   Gap(20.h),
//                                   _buildSaveButton(context, cubit, state),
//                                   Gap(40.h),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: Icon(Icons.arrow_back, color: AppColors.blackColor),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 18.0),
//           child: Text(
//             'المواعيد',
//             style: Styles.textStyle20Bold.copyWith(
//               color: AppColors.secondary800,
//             ),
//           ),
//         ),
//         const SizedBox(width: 24),
//       ],
//     );
//   }

//   Widget _buildTimeSlotsList(
//     BuildContext context,
//     AppointmentsState state,
//     AppointmentsCubit cubit,
//   ) {
//     final weeklyAvailability = state.weeklyAvailability;

//     return ListView.separated(
//       itemCount: weeklyAvailability.length,
//       separatorBuilder: (context, index) => Gap(20.h),
//       itemBuilder: (context, index) {
//         final day = weeklyAvailability[index];
//         final timeSlot = day.timeSlots.isNotEmpty ? day.timeSlots.first : null;

//         return TimeSlotItem(
//           name: day.dayName,
//           initialFrom: timeSlot?.start ?? '09:00',
//           initialTo: timeSlot?.end ?? '17:00',
//           initialStatus: day.isEnabled,
//           onStatusChanged: (isActive) {
//             cubit.toggleDayStatus(day.dayOfWeek, isActive);
//           },
//           onTimeChanged: (start, end) {
//             cubit.updateDayTimeSlot(day.dayOfWeek, start, end);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildSaveButton(
//     BuildContext context,
//     AppointmentsCubit cubit,
//     AppointmentsState state,
//   ) {
//     return CustomBotton(
//       width: context.width * 0.9,
//       useGradient: true,
//       title: state.isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
//       onPressed: state.isSaving ? null : () => cubit.saveChanges(),
//     );
//   }
// }
