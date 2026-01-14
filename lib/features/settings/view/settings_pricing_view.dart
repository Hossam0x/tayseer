import 'package:tayseer/features/settings/view/widgets/session_price_item.dart';
import 'package:tayseer/my_import.dart';

class SessionPricingView extends StatelessWidget {
  const SessionPricingView({super.key});

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
                    Expanded(child: _buildPricingList()),
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
          child: Icon(
            Icons.arrow_back,
            color: AppColors.blackColor,
            size: 24.w,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            'مدة واسعار الجلسات',
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  Widget _buildPricingList() {
    final sessions = [
      {'duration': '30 دقيقة', 'price': '120', 'isActive': true},
      {'duration': '60 دقيقة', 'price': '210', 'isActive': true},
    ];

    return ListView.separated(
      itemCount: sessions.length,
      separatorBuilder: (context, index) => Gap(20.h),
      itemBuilder: (context, index) {
        return SessionPriceItem(
          duration: sessions[index]['duration'] as String,
          initialPrice: sessions[index]['price'] as String,
          initialStatus: sessions[index]['isActive'] as bool,
        );
      },
    );
  }
}

// import 'package:tayseer/features/settings/view/cubit/service_provider_cubits.dart';
// import 'package:tayseer/features/settings/view/cubit/service_provider_states.dart';
// import 'package:tayseer/features/settings/view/widgets/session_price_item.dart';
// import 'package:tayseer/my_import.dart';

// class SessionPricingView extends StatelessWidget {
//   const SessionPricingView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider<SessionPricingCubit>(
//       create: (_) => getIt<SessionPricingCubit>(),
//       child: BlocConsumer<SessionPricingCubit, SessionPricingState>(
//         listener: (context, state) {
//           if (state.errorMessage != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               CustomSnackBar(context, text: state.errorMessage!, isError: true),
//             );
//             context.read<SessionPricingCubit>().clearError();
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
//           final cubit = context.read<SessionPricingCubit>();

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
//                                     child: _buildPricingList(
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
//           child: Icon(
//             Icons.arrow_back,
//             color: AppColors.blackColor,
//             size: 24.w,
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(top: 18.0),
//           child: Text(
//             'مدة واسعار الجلسات',
//             style: Styles.textStyle20Bold.copyWith(
//               color: AppColors.secondary800,
//             ),
//           ),
//         ),
//         const SizedBox(width: 24),
//       ],
//     );
//   }

//   Widget _buildPricingList(
//     BuildContext context,
//     SessionPricingState state,
//     SessionPricingCubit cubit,
//   ) {
//     final sessionTypes = state.sessionTypes;

//     return ListView.separated(
//       itemCount: sessionTypes.length,
//       separatorBuilder: (context, index) => Gap(20.h),
//       itemBuilder: (context, index) {
//         final sessionKey = sessionTypes.keys.elementAt(index);
//         final session = sessionTypes[sessionKey]!;

//         return SessionPriceItem(
//           duration: session.durationText,
//           initialPrice: session.price.toString(),
//           initialStatus: session.isEnabled,
//           onPriceChanged: (price) {
//             final priceInt = int.tryParse(price) ?? 0;
//             cubit.updateSessionPrice(sessionKey, priceInt);
//           },
//           onStatusChanged: (isActive) {
//             cubit.toggleSessionStatus(sessionKey, isActive);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildSaveButton(
//     BuildContext context,
//     SessionPricingCubit cubit,
//     SessionPricingState state,
//   ) {
//     return CustomBotton(
//       width: context.width * 0.9,
//       useGradient: true,
//       title: state.isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
//       onPressed: state.isSaving ? null : () => cubit.saveChanges(),
//     );
//   }
// }
