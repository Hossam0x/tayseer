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

    final itemCount = package.features.length;
    final rows = (itemCount / 3).ceil();
    final lastRowItemCount = itemCount % 3 == 0 ? 3 : itemCount % 3;

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
              final startIndex = rowIndex * 3;
              final endIndex = (startIndex + 3).clamp(0, itemCount);
              final rowItems = package.features.sublist(startIndex, endIndex);
              final isLastRow = rowIndex == rows - 1;
              final shouldCenter = isLastRow && lastRowItemCount < 3;

              return Padding(
                padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? 20.h : 0),
                child: Row(
                  mainAxisAlignment: shouldCenter
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: rowItems.asMap().entries.map((entry) {
                    // final itemIndex = entry.key;
                    final feature = entry.value;
                    return Container(
                      width: (MediaQuery.of(context).size.width - 35.w) / 3.5,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: _FeatureItem(
                        feature: feature,
                        iconColor: iconColor,
                        textColor: textColor,
                      ),
                    );
                  }).toList(),
                ),
              );
            }),
          ),
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
                height: 28.h,
              )
            : Image.asset(feature.iconPath, height: 28.h),
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
