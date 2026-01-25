
import 'package:tayseer/my_import.dart';

class FilterChips extends StatefulWidget {
  final Function(String)? onFilterChanged;

  const FilterChips({super.key, this.onFilterChanged}); 
  @override
  _FilterChipsState createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  final List<String> _filters = [
    "المفضلة",
    "نال إعجابك",
    "صادفتهم",
    "أرسلت مجاملة",
  ];
  // State variable to manage which item is currently selected
  String _selectedFilter = "نال إعجابك"; // Default selected item

  @override
  Widget build(BuildContext context) {
    // This top level container provides the overall background and rounded shape
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.width * 0.07,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Light background color for the container
        borderRadius: BorderRadius.circular(12.0.r),
        border: Border.all(color: Color(0xffF9F8EC), width: 1.0.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _filters.map((filterName) {
          final bool isSelected = _selectedFilter == filterName;

          return Expanded(
            // Ensures even distribution of space
            child: GestureDetector(
              onTap: () {
                // Update the state when a filter is tapped
                setState(() {
                  _selectedFilter = filterName;
                });
                   widget.onFilterChanged?.call(filterName);
              },
              child: AnimatedContainer(
                duration: Duration(
                  milliseconds: 300,
                ), // Smooth animation duration

                curve: Curves.easeInOut,
                // The inner container acts as the sliding background indicator
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary100
                      : Colors.transparent, // Pink when selected
                  borderRadius: BorderRadius.circular(8.0.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 15.0.h),
                alignment:
                    Alignment.center, // Centers the text within the segment
                child: Text(
                  filterName,
                  textAlign: TextAlign.center,
                  style: isSelected
                      // Use your defined Styles for selected state
                      ? Styles.textStyle14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary800,
                        )
                      // Use your defined Styles for unselected state
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
