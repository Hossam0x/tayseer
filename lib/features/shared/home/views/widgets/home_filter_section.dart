import 'package:tayseer/my_import.dart';

class HomeFilterSection extends StatefulWidget {
  const HomeFilterSection({super.key});

  @override
  State<HomeFilterSection> createState() => _HomeFilterSectionState();
}

class _HomeFilterSectionState extends State<HomeFilterSection> {
  int _selectedIndex = 0;

  static const List<String> _filters = [
    "الكل",
    "جديد",
    "المقبلين على الزواج",
    "محبين السفر",
    "المخطوبين",
  ];

  void _onFilterSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        // 1. نقلنا المارجن هنا عشان يبقى مسافة خارجية للسكشن كله
        padding: EdgeInsets.only(
          bottom: context.responsiveHeight(10),
          right: context.responsiveWidth(24),
          left: context.responsiveWidth(24),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.asMap().entries.map((entry) {
              int idx = entry.key;
              String title = entry.value;

              return Row(
                children: [
                  _FilterItem(
                    title: title,
                    isSelected: _selectedIndex == idx,
                    onTap: () => _onFilterSelected(idx),
                  ),
                  // 3. إضافة المسافة بين العناصر يدوياً بدلاً من separated
                  if (idx != _filters.length - 1)
                    Gap(context.responsiveWidth(8)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _FilterItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: EdgeInsets.symmetric(
          horizontal: context.responsiveWidth(12),
          vertical: context.responsiveHeight(8), // ده اللي بيعمل الطول
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kprimaryColor.withOpacity(0.6)
              : const Color(0xB8F9F8EC),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Text(
          title,
          style: Styles.textStyle14.copyWith(
            color: isSelected ? Colors.black : AppColors.kGreyB3,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
