import 'package:tayseer/features/advisor/profille/view_model/models/analysis_item.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/analytics_chart.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button.dart';
import 'package:tayseer/my_import.dart';

class ProfessionalInfoDashboardView extends StatefulWidget {
  const ProfessionalInfoDashboardView({super.key});

  @override
  State<ProfessionalInfoDashboardView> createState() =>
      _ProfessionalInfoDashboardViewState();
}

class _ProfessionalInfoDashboardViewState
    extends State<ProfessionalInfoDashboardView> {
  // بيانات التحليلات السفلية
  final List<AnalysisItem> _analysisItems = [
    AnalysisItem(subtitle: '3,445,789', title: 'الزيارات'),
    AnalysisItem(subtitle: '1,234', title: 'الزيارات'),
    AnalysisItem(subtitle: '567', title: 'المتابعين الجدد'),
    AnalysisItem(subtitle: '45,678', title: 'المشاهدات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // زر العودة
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.blackColor,
                        size: 24.w,
                      ),
                    ),
                  ),
                ),

                // العنوان
                Gap(16.h),
                Center(
                  child: Text(
                    'لوحة المعلومات الاحترافية',
                    style: Styles.textStyle24Bold.copyWith(
                      color: AppColors.secondary800,
                    ),
                  ),
                ),

                Gap(32.h),

                AnalyticsChart(),
                Gap(32.h),

                // قسم التحليلات السفلية
                _buildAnalysisSection(),

                Spacer(),
                BoostButton(),
              ],
            ),
          ),
        ),
      ),
    );
  } // قسم التحليلات السفلية

  Widget _buildAnalysisSection() {
    return Column(
      children: [
        // قائمة التحليلات
        Column(
          children: _analysisItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildAnalysisItem(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  // عنصر التحليل
  Widget _buildAnalysisItem(AnalysisItem item) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.kWhiteColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.title,
            style: Styles.textStyle18SemiBold.copyWith(
              color: AppColors.blackColor,
            ),
          ),
          Text(
            item.subtitle,
            style: Styles.textStyle16.copyWith(color: AppColors.primary900),
          ),
        ],
      ),
    );
  }
}
