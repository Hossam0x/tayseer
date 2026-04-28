import 'package:tayseer/features/advisor/settings/view/advisor_terms_view.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/summary_country_card.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/summary_empty_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/summary_stats_banner.dart';
import 'package:tayseer/my_import.dart';

class UpdateOfferingsSummaryBody extends StatelessWidget {
  const UpdateOfferingsSummaryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateOfferingsCubit, UpdateOfferingsState>(
      builder: (context, state) {
        final cubit = context.read<UpdateOfferingsCubit>();
        final summaryData = state.summaryList;

        return Column(
          children: [
            Expanded(
              child: summaryData.isEmpty
                  ? SummaryEmptyState(cubit: cubit)
                  : ListView(
                      children: [
                        SummaryStatsBanner(data: summaryData),
                        Gap(16.h),
                        ...List.generate(
                          summaryData.length,
                          (i) => SummaryCountryCard(
                            country: summaryData[i],
                            index: i,
                            cubit: cubit,
                          ),
                        ),
                      ],
                    ),
            ),

            Gap(12.h),
            GestureDetector(
              onTap: () => cubit.goToAddAnotherCountry(),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.kprimaryColor,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+ ${context.tr('add_another_country')}',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.kprimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Gap(12.h),
            CustomBotton(
              height: 54.h,
              width: double.infinity,
              useGradient: summaryData.isNotEmpty,
              title: state.isSaving
                  ? context.tr('sending')
                  : '${context.tr('finish_and_save')} ✓',
              backGroundcolor: summaryData.isNotEmpty
                  ? null
                  : AppColors.inactiveColor,
              onPressed: summaryData.isNotEmpty && !state.isSaving
                  ? () => Navigator.pushNamed(
                      context,
                      AppRouter.kAdvisorTermsView,
                      arguments: AdvisorTermsArgs(
                        onAccept: () => cubit.submitOfferings(),
                      ),
                    )
                  : null,
            ),
            Gap(20.h),
          ],
        );
      },
    );
  }
}
