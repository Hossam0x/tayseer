import 'package:tayseer/features/user/consultation_filtter/presentation/widgets/advisor_consultation_card.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/filter/presentation/view/advisor_filter_view.dart';

import '../widgets/search_bar_with_filter.dart';

class ConsultationStandalonePage extends StatelessWidget {
  const ConsultationStandalonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdvisorBackground(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              Text(
                context.tr("Consulting"),
                style: Styles.textStyle24Meduim.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondary700,
                ),
              ),
              SizedBox(height: 24.h),
              SearchBarWithFilter(
                isReadOnly: true,
                onFilterTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdvisorFilterView()),
                ),
                onTap: () {
                   Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdvisorFilterView()),
                );
                },
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.separated(
                  itemCount: 3, // replace with actual data
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return AdvisorConsultationCard(
                      isSelected:
                          index ==
                          0, // ✅ first card highlighted, rest are normal
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:tayseer/features/user/consultation_filtter/presentation/consultation_filtter_cubit/consultation_filtter_cubit.dart';
// import 'package:tayseer/features/user/consultation_filtter/presentation/consultation_filtter_cubit/consultation_filtter_state.dart';
// import 'package:tayseer/features/user/consultation_filtter/presentation/widgets/advisor_consultation_card.dart';
// import 'package:tayseer/features/filter/data/models/advisor_filter_request_model.dart';
// import 'package:tayseer/my_import.dart';
// import 'package:tayseer/features/filter/presentation/view/advisor_filter_view.dart';
// import '../widgets/search_bar_with_filter.dart';

// class ConsultationStandalonePage extends StatelessWidget {
//   const ConsultationStandalonePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => ConsultationCubit(),
//       child: const _ConsultationView(),
//     );
//   }
// }

// class _ConsultationView extends StatelessWidget {
//   const _ConsultationView();

//   Future<void> _openFilter(BuildContext context) async {
//     final result = await Navigator.push<AdvisorFilterRequestModel>(
//       context,
//       MaterialPageRoute(builder: (_) => const AdvisorFilterView()),
//     );

//     if (result != null && context.mounted) {
//       context.read<ConsultationCubit>().applyFilter(result);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AdvisorBackground(
//       child: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//           child: Column(
//             children: [
//               Text(
//                 context.tr("Consulting"),
//                 style: Styles.textStyle24Meduim.copyWith(
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.secondary700,
//                 ),
//               ),
//               SizedBox(height: 24.h),
//               SearchBarWithFilter(
//                 isReadOnly: true,
//                 onFilterTap: () => _openFilter(context),
//                 onTap: () => _openFilter(context),
//               ),
//               SizedBox(height: 20.h),
//               Expanded(child: _buildBody(context)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return BlocBuilder<ConsultationCubit, ConsultationState>(
//       builder: (context, state) {

//         // ─── Initial ─────────────────────────────────────────────────────
//         if (state.status == ConsultationStatus.initial) {
//           return Center(
//             child: Text(
//               context.tr("use_filter_to_search"),
//               style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
//             ),
//           );
//         }

//         // ─── Loading ──────────────────────────────────────────────────────
//         if (state.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         // ─── Failure ──────────────────────────────────────────────────────
//         if (state.isFailure) {
//           return Center(
//             child: Text(
//               state.errorMessage ?? context.tr("something_went_wrong"),
//               style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
//             ),
//           );
//         }

//         // ─── Empty ────────────────────────────────────────────────────────
//         if (state.isEmpty) {
//           return Center(
//             child: Text(
//               context.tr("no_advisors_found"),
//               style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
//             ),
//           );
//         }

//         // ─── Success ──────────────────────────────────────────────────────
//         return NotificationListener<ScrollEndNotification>(
//           onNotification: (notification) {
//             if (notification.metrics.extentAfter == 0) {
//               context.read<ConsultationCubit>().loadMore();
//             }
//             return false;
//           },
//           child: ListView.separated(
//             itemCount:
//                 state.advisors.length + (state.isLoadingMore ? 1 : 0),
//             separatorBuilder: (_, __) => SizedBox(height: 12.h),
//             itemBuilder: (context, index) {
//               if (index == state.advisors.length) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final advisor = state.advisors[index];
//               return AdvisorConsultationCard(
//                 advisor: advisor,
//                 isSelected: advisor.isRecommended,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }