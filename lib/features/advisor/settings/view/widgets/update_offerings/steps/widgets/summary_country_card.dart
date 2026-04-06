import 'package:tayseer/features/advisor/settings/data/models/offerings_model.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/offerings/update_offerings_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/update_offerings/steps/widgets/summary_offering_row.dart';
import 'package:tayseer/my_import.dart';

class SummaryCountryCard extends StatelessWidget {
  const SummaryCountryCard({
    super.key,
    required this.country,
    required this.index,
    required this.cubit,
  });

  final CountryOfferingsModel country;
  final int index;
  final UpdateOfferingsCubit cubit;

  @override
  Widget build(BuildContext context) {
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
          // Country header
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

          // Offerings list
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              children: [
                ...List.generate(
                  country.offerings.length,
                  (oi) => SummaryOfferingRow(
                    offering: country.offerings[oi],
                    onDelete: () => cubit.removeOfferingFromSummary(
                      countryIndex: index,
                      offeringIndex: oi,
                    ),
                  ),
                ),
                Gap(6.h),
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
}
