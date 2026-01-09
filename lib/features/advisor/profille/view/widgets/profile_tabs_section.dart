import 'package:tayseer/my_import.dart';

class ProfileTabsSection extends StatefulWidget {
  const ProfileTabsSection({super.key});

  @override
  State<ProfileTabsSection> createState() => _ProfileTabsSectionState();
}

class _ProfileTabsSectionState extends State<ProfileTabsSection> {
  int _selectedIndex = 0;

  final List<String> _tabs = [
    "الاستفسارات",
    "المنشورات",
    "التعليقات",
    "الشهادات",
    "التقييمات",
  ];

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _tabs.asMap().entries.map((entry) {
                  int idx = entry.key;
                  String title = entry.value;
                  bool isSelected = _selectedIndex == idx;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = idx);
                      // TODO: Handle tab change (load different content)
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.5.w),
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: isSelected
                                ? Styles.textStyle16Bold.copyWith(
                                    color: AppColors.blackColor,
                                  )
                                : Styles.textStyle16.copyWith(
                                    color: AppColors.secondary400,
                                  ),
                          ),
                          Gap(8.h),
                          if (isSelected)
                            Container(
                              width: 80.w,
                              height: 1.h,
                              color: AppColors.blackColor,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Divider(height: 1.h, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
