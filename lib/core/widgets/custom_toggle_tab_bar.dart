import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';

class CustomToggleTabBar extends StatefulWidget {
  final String firstTabText;
  final String secondTabText;
  final ValueChanged<int>? onTabChanged;
  final int initialIndex;

  const CustomToggleTabBar({
    super.key,
    required this.firstTabText,
    required this.secondTabText,
    this.onTabChanged,
    this.initialIndex = 0,
  });

  @override
  State<CustomToggleTabBar> createState() => _CustomToggleTabBarState();
}

class _CustomToggleTabBarState extends State<CustomToggleTabBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // ده المهم: نحدث الـ selected index لما الـ initialIndex يتغير
  @override
  void didUpdateWidget(CustomToggleTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: AppColors.tabsBack,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Row(
        children: [
          _buildTab(0, widget.firstTabText),
          _buildTab(1, widget.secondTabText),
        ],
      ),
    ),
        SizedBox(height: 22.h),
      ],
    );
  }

  Widget _buildTab(int index, String text) {
    final isSelected = _selectedIndex == index;
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          widget.onTabChanged?.call(index);
        },
        child: Container(
          padding: isTablet
              ? EdgeInsets.symmetric(vertical: 12.h)
              : EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary300 : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              text,
              style: isSelected
                  ? (isTablet ? Styles.textStyle16 : Styles.textStyle16)
                        .copyWith(
                          color: AppColors.secondary950,
                          fontWeight: FontWeight.w600,
                        )
                  : Styles.textStyle16.copyWith(color: AppColors.blackColor),
            ),
          ),
        ),
      ),
    );
  }
}
