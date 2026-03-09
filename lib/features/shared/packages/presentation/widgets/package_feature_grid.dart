import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/features/shared/packages/data/models/package_display_model.dart';
import 'package:tayseer/features/shared/packages/data/models/package_feature_model.dart';

class PackageFeatureGrid extends StatelessWidget {
  final PackageDisplayModel package;

  const PackageFeatureGrid({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor();
    final textColor = _getTextColor();
    final itemCount = package.features.length;
    final rows = (itemCount / 3).ceil();

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
          child: Column(
            children: List.generate(rows, (rowIndex) {
              return _buildRow(
                context,
                rowIndex,
                rows,
                itemCount,
                iconColor,
                textColor,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    int rowIndex,
    int totalRows,
    int itemCount,
    Color iconColor,
    Color textColor,
  ) {
    final startIndex = rowIndex * 3;
    final endIndex = (startIndex + 3).clamp(0, itemCount);
    final rowItems = package.features.sublist(startIndex, endIndex);
    final isLastRow = rowIndex == totalRows - 1;
    final lastRowItemCount = itemCount % 3 == 0 ? 3 : itemCount % 3;
    final shouldCenter = isLastRow && lastRowItemCount < 3;

    return Row(
      mainAxisAlignment: shouldCenter
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: rowItems.map((feature) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 35.w) / 3.5,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: _FeatureItem(
              feature: feature,
              iconColor: iconColor,
              textColor: textColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getIconColor() {
    if (package.id == 'basic') {
      return AppColors.primary400;
    } else if (package.id == 'pro') {
      return const Color(0xFFCF9916);
    } else {
      return const Color(0xFFFEC155);
    }
  }

  Color _getTextColor() {
    return package.id == 'elite' ? Colors.white : const Color(0xFF1A1A1A);
  }
}

class _FeatureItem extends StatelessWidget {
  final PackageFeatureModel feature;
  final Color iconColor;
  final Color textColor;

  const _FeatureItem({
    required this.feature,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [_buildIcon(), Gap(12.h), _buildTitle()],
    );
  }

  Widget _buildIcon() {
    return feature.iconPath.endsWith('.svg')
        ? SvgPicture.asset(
            feature.iconPath,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            height: 32.h,
          )
        : Image.asset(feature.iconPath, height: 32.h);
  }

  Widget _buildTitle() {
    return SizedBox(
      width: 75.w,
      child: Text(
        feature.title,
        textAlign: TextAlign.center,
        style: Styles.textStyle12SemiBold.copyWith(color: textColor),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
