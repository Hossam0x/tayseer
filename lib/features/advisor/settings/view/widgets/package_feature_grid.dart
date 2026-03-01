import 'package:tayseer/features/advisor/settings/data/models/package_model.dart';
import 'package:tayseer/my_import.dart';

class PackageFeatureGrid extends StatelessWidget {
  final PackageModel package;

  const PackageFeatureGrid({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    Color iconColor;
    if (package.id == 'basic') {
      iconColor = AppColors.primary400;
    } else if (package.id == 'pro') {
      iconColor = const Color(0xFFCF9916);
    } else {
      iconColor = const Color(0xFFFEC155);
    }

    final textColor = package.id == 'elite'
        ? Colors.white
        : const Color(0xFF1A1A1A);

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
        child: GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 20.w,
            mainAxisSpacing: 0.h,
            childAspectRatio: 0.95,
          ),
          itemCount: package.features.length,
          itemBuilder: (context, index) {
            final feature = package.features[index];
            return _FeatureItem(
              feature: feature,
              iconColor: iconColor,
              textColor: textColor,
            );
          },
        ),
      ),
    );
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
      children: [
        feature.iconPath.endsWith('.svg')
            ? SvgPicture.asset(
                feature.iconPath,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                height: 32.h,
              )
            : Image.asset(feature.iconPath, height: 32.h),
        Gap(12.h),
        SizedBox(
          width: 75.w,
          child: Text(
            feature.title,
            textAlign: TextAlign.center,
            style: Styles.textStyle12SemiBold.copyWith(color: textColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
