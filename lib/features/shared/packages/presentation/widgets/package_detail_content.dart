import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/features/shared/packages/data/models/package_display_model.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/package_feature_grid.dart';

class PackageDetailContent extends StatelessWidget {
  final PackageDisplayModel package;
  final PackageType packageType;

  const PackageDetailContent({
    super.key,
    required this.package,
    required this.packageType,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildTitle(context),
            Gap(40.h),
            PackageFeatureGrid(package: package),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    switch (packageType) {
      case PackageType.elite:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                package.packageTitle,
                textAlign: TextAlign.center,
                style: Styles.textStyle24Meduim.copyWith(
                  color: AppColors.primary50,
                ),
              ),
            ),
          ],
        );

      case PackageType.pro:
        return Text(
          package.packageTitle,
          textAlign: TextAlign.center,
          style: Styles.textStyle24Meduim.copyWith(
            color: AppColors.secondary800,
          ),
        );

      case PackageType.basic:
        return Text(
          package.packageTitle,
          textAlign: TextAlign.center,
          style: Styles.textStyle24Meduim.copyWith(
            color: AppColors.primary500,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }
}
