import 'package:tayseer/features/advisor/search/presentation/view/search_tab.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/advisor/search/presentation/cubit/advisor_search_ui_cubit.dart';

class AdvisorSearchTabsWidget extends StatelessWidget {
  final List<SearchTab> tabs;
  final TabController tabController;
  final Function(int) onTabTap;

  const AdvisorSearchTabsWidget({
    super.key,
    required this.tabs,
    required this.tabController,
    required this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvisorSearchUiCubit, AdvisorSearchUiState>(
      builder: (context, state) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: EdgeInsetsDirectional.only(bottom: 10.h, start: 20.w),
            child: Row(
              children: [
                // جميع التبويبات
                ...tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = index == state.selectedIndex;

                  return Padding(
                    padding: EdgeInsets.only(left: 10.w),
                    child: GestureDetector(
                      onTap: () {
                        tabController.animateTo(index);
                        onTabTap(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary100
                              : const Color(0xB8F9F8EC),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          context.tr(tab.title),
                          style: isSelected
                              ? Styles.textStyle14Meduim.copyWith(
                                  color: AppColors.secondary800,
                                )
                              : Styles.textStyle14.copyWith(
                                  color: AppColors.secondary600,
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
