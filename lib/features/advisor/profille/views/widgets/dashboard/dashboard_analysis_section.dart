import 'package:tayseer/features/advisor/profille/data/models/analysis_item.dart';
import 'package:tayseer/features/advisor/profille/data/models/analytics_model.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/dashboard_analysis_item.dart';
import 'package:tayseer/my_import.dart';

class DashboardAnalysisSection extends StatelessWidget {
  final AnalyticsOverview? overview;

  const DashboardAnalysisSection({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final items = [
      AnalysisItem(
        title: context.tr('who_viewed_profile'),
        subtitle: '${overview?.views ?? 0}',
        isViewProfile: true,
      ),
      AnalysisItem(
        title: context.tr('views'),
        subtitle: '${overview?.views ?? 0}',
      ),
      AnalysisItem(
        title: context.tr('visits'),
        subtitle: '${overview?.visits ?? 0}',
      ),
      AnalysisItem(
        title: context.tr('new_followers'),
        subtitle: '${overview?.newFollowers ?? 0}',
      ),
      AnalysisItem(
        title: context.tr('interactions'),
        subtitle: '${overview?.interactions ?? 0}',
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: DashboardAnalysisItem(item: item, overview: overview),
            ),
          )
          .toList(),
    );
  }
}
