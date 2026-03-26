import 'package:tayseer/features/shared/profile/cubit/profile_tabs_cubit.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/my_import.dart';

/// Shared tab bar used by both advisor and user-advisor profile tab sections.
/// Handles tab switching, swipe sync, and the divider line.
class ProfileTabBar extends StatelessWidget {
  final TabController tabController;
  final List<String> tabs;
  final ProfileTabsCubit tabsCubit;

  const ProfileTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
    required this.tabsCubit,
  });

  @override
  Widget build(BuildContext context) {
    final bool isArabic =
        context.read<LanguageCubit>().state.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Transform.translate(
                offset: Offset(isArabic ? 110.w : -110.w, 0),
                child: TabBar(
                  controller: tabController,
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  indicatorColor: AppColors.blackColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.blackColor,
                        width: 1.5.h,
                      ),
                    ),
                  ),
                  dividerHeight: 0,
                  labelColor: AppColors.blackColor,
                  unselectedLabelColor: AppColors.secondary400,
                  labelStyle: Styles.textStyle16Bold,
                  unselectedLabelStyle: Styles.textStyle14,
                  tabs: tabs.map((tab) {
                    return Tab(
                      height: 33.w,
                      child: Column(
                        children: [
                          Text(context.tr(tab)),
                          Gap(4.h),
                          Container(width: 75.w, color: Colors.transparent),
                        ],
                      ),
                    );
                  }).toList(),
                  onTap: tabsCubit.changeTab,
                ),
              ),
            ],
          ),
          Divider(height: 1.h, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
