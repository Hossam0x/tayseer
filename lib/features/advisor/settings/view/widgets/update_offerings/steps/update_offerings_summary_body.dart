import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_state.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/shared/offerings_item_chip.dart';
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
            // المحتوى
            Expanded(
              child: summaryData.isEmpty
                  ? _buildEmptyState(context, cubit)
                  : ListView(
                      children: [
                        _buildStatsBanner(summaryData, context),
                        Gap(16.h),
                        ...List.generate(
                          summaryData.length,
                          (i) => _buildCountryCard(
                            summaryData[i],
                            i,
                            context,
                            cubit,
                          ),
                        ),
                      ],
                    ),
            ),

            // الأزرار السفلية
            Gap(12.h),
            // إضافة دولة جديدة
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
            // حفظ
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
                  ? () => cubit.submitOfferings()
                  : null,
            ),
            Gap(20.h),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, UpdateOfferingsCubit cubit) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.pink.shade100, width: 2),
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.pink.shade200,
              size: 48,
            ),
          ),
          Gap(16.h),
          Text(
            context.tr('no_sessions_added_yet'),
            style: Styles.textStyle16.copyWith(
              color: AppColors.kprimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(24.h),
          CustomBotton(
            width: context.width * .65,
            title: '+ ${context.tr('add_another_country')}',
            useGradient: true,
            onPressed: () => cubit.goToAddAnotherCountry(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBanner(
    List<CountryOfferingsModel> data,
    BuildContext context,
  ) {
    final total = data.fold(0, (sum, c) => sum + c.offerings.length);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFA62A3B),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 18),
          ),
          Column(
            children: [
              Text(
                context.tr('sessions_ready'),
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFA62A3B),
                ),
              ),
              Text(
                '${data.length} ${context.tr('countries_word')} · $total ${context.tr('session_word')}',
                style: Styles.textStyle10.copyWith(color: Colors.pink.shade300),
              ),
            ],
          ),
          const Icon(
            Icons.assignment_turned_in,
            color: Color(0xFFA62A3B),
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCard(
    CountryOfferingsModel country,
    int index,
    BuildContext context,
    UpdateOfferingsCubit cubit,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // هيدر الدولة
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => cubit.removeCountryFromSummary(index),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.red.shade400,
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isArabic
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(country.countryKey),
                        style: Styles.textStyle14.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${country.offerings.length} ${context.tr('added_sessions_subtitle')}',
                        style: Styles.textStyle10.copyWith(
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(country.flagEmoji, style: const TextStyle(fontSize: 22)),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade100, height: 1, thickness: 1),

          // الـ offerings
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              children: [
                ...List.generate(
                  country.offerings.length,
                  (oi) => _buildOfferingRow(
                    country.offerings[oi],
                    context,
                    onDelete: () => cubit.removeOfferingFromSummary(
                      countryIndex: index,
                      offeringIndex: oi,
                    ),
                  ),
                ),
                Gap(6.h),
                // زر إضافة لهذه الدولة
                GestureDetector(
                  onTap: () => cubit.addToExistingCountry(
                    countryKey: country.countryKey,
                    flagEmoji: country.flagEmoji,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.kprimaryColor.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColors.kprimaryColor.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: AppColors.kprimaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('add_session_to_list'),
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.kprimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingRow(
    OfferingItemModel offering,
    BuildContext context, {
    VoidCallback? onDelete,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 13, color: Colors.red.shade400),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              offering.name,
              style: Styles.textStyle14.copyWith(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Wrap(
            spacing: 4,
            children: [
              OfferingsItemChip(
                text: '${offering.price} ${offering.currency}',
                isGreen: true,
              ),
              OfferingsItemChip(
                text: '${offering.duration}${context.tr('minute_shortcut')}',
              ),
              OfferingsItemChip(
                text: offering.type == 'package'
                    ? context.tr('package_type')
                    : context.tr('individual_type'),
                isPink: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
