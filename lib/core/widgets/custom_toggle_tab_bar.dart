import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';

class CustomToggleTabBar extends StatelessWidget {
  final String firstTabText;
  final String secondTabText;

  const CustomToggleTabBar({
    super.key,
    required this.firstTabText,
    required this.secondTabText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w, vertical: 5.h),
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: AppColors.tabsBack,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppColors.primary300,
          borderRadius: BorderRadius.circular(12.r),
        ),
        labelStyle: Styles.textStyle16Bold,
        labelColor: AppColors.secondary950,
        unselectedLabelColor: AppColors.blackColor,
        tabs: [
          Tab(text: firstTabText),
          Tab(text: secondTabText),
        ],
      ),
    );
  }
}
