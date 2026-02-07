import 'package:tayseer/my_import.dart';

class FilterChips extends StatefulWidget {
  final Function(String)? onFilterChanged;
  const FilterChips({super.key, this.onFilterChanged});

  @override
  _FilterChipsState createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  // ✅ استخدام مفاتيح الترجمة بدلاً من النصوص المباشرة
  late final List<FilterItem> _filters;
  String _selectedFilterKey = "liked_you"; // Default selected key

  @override
  void initState() {
    super.initState();
    // ✅ تعريف الفلاتر مع مفاتيح الترجمة
    _filters = [
      FilterItem(key: "favorites", labelKey: "favorites"),
      FilterItem(key: "liked_you", labelKey: "liked_you"),
      FilterItem(key: "met_them", labelKey: "met_them"),
      FilterItem(key: "sent_compliment", labelKey: "sent_compliment"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.width * 0.07,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12.0.r),
        border: Border.all(color: Color(0xffF9F8EC), width: 1.0.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _filters.map((filter) {
          final bool isSelected = _selectedFilterKey == filter.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterKey = filter.key;
                });
                // ✅ إرجاع النص المترجم
                widget.onFilterChanged?.call(context.tr(filter.labelKey));
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.0.h),
                alignment: Alignment.center,
                child: Text(
                  context.tr(filter.labelKey), // ✅ ترجمة
                  textAlign: TextAlign.center,
                  style: isSelected
                      ? Styles.textStyle14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary800,
                        )
                      : Styles.textStyle14.copyWith(
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondary600,
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ✅ Model للفلتر
class FilterItem {
  final String key;
  final String labelKey;

  FilterItem({required this.key, required this.labelKey});
}