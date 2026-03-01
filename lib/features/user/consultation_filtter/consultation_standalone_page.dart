import 'package:tayseer/features/user/consultation_filtter/advisor_consultation_card.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/filter/presentation/view/advisor_filter_view.dart';

import 'search_bar_with_filter.dart';

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

