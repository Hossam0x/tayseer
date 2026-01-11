import 'package:tayseer/features/advisor/profille/views/widgets/boost/age_range_selector.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/billing_summary.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/selection_tile.dart';
import '../../../../my_import.dart';

class BoostPropertiesView extends StatelessWidget {
  const BoostPropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Gap(16.h),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_back, color: AppColors.blackColor),
                  ),
                ),
              ),
              Text('خصائص التعزيز الفعّالة', style: Styles.textStyle20Bold),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Gap(20.h),
                      // 1. Age Range Section
                      const AgeRangeSelector(),

                      Gap(16.h),
                      // 2. Location Selector
                      SelectionTile(
                        label: 'الموقع',
                        value: 'مصر',
                        onTap: () {},
                      ),

                      Gap(16.h),
                      // 3. Consultation Topics
                      SelectionTile(
                        label: 'مواضيع الاستشارات',
                        value: 'العلاج والتوجيه الزوجي',
                        onTap: () {},
                      ),

                      Gap(40.h),

                      // 4. Billing Details
                    ],
                  ),
                ),
              ),
              const BillingSummary(),
              // 5. Bottom Action Button
              CustomBotton(
                title: 'اشتراك',
                onPressed: () {},
                useGradient: true,
              ),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }
}
