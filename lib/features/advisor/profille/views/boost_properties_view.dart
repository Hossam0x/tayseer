import 'package:tayseer/core/widgets/simple_app_bar.dart';
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SimpleAppBar(
                  title: 'خصائص التعزيز الفعّالة',
                  isLargeTitle: true,
                ),
              ),
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
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.kLocationSelectionView,
                          );
                        },
                      ),

                      Gap(16.h),
                      // 3. Consultation Topics
                      SelectionTile(
                        label: 'مواضيع الاستشارات',
                        value: 'العلاج والتوجيه الزوجي',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.kConsultationTopicsView,
                          );
                        },
                      ),

                      Gap(40.h),

                      // 4. Billing Details
                    ],
                  ),
                ),
              ),
              const BillingSummary(),
              // 5. Bottom Action Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: CustomBotton(
                  height: 54.h,
                  width: double.infinity,
                  title: 'اشتراك',
                  onPressed: () {},
                  useGradient: true,
                ),
              ),
              Gap(20.h),
            ],
          ),
        ),
      ),
    );
  }
}
