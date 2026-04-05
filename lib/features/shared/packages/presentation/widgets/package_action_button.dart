import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';

class PackageActionButton extends StatelessWidget {
  final PackageType packageType;
  final VoidCallback onPressed;

  /// هل المستخدم مشترك حالياً في هذه الباقة؟
  final bool isCurrentSub;

  const PackageActionButton({
    super.key,
    required this.packageType,
    required this.onPressed,
    this.isCurrentSub = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getButtonConfig(context);

    return Center(
      child: Container(
        width: 360.w,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11.r),
          gradient: LinearGradient(
            colors: config.gradientColors,
            begin: config.isVertical
                ? Alignment.topCenter
                : Alignment.centerRight,
            end: config.isVertical
                ? Alignment.bottomCenter
                : Alignment.centerLeft,
          ),
          border: config.hasBorder
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
          boxShadow: config.hasShadow
              ? [
                  BoxShadow(
                    color: const Color(0xFF6284FF).withOpacity(0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.r),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            config.buttonText,
            style: Styles.textStyle18SemiBold.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  _ButtonConfig _getButtonConfig(BuildContext context) {
    switch (packageType) {
      case PackageType.basic:
        return _ButtonConfig(
          buttonText: context.tr('continue_limited_account'),
          gradientColors: [AppColors.primary300, AppColors.primary500],
          isVertical: true,
          hasBorder: false,
          hasShadow: false,
        );

      case PackageType.pro:
        return _ButtonConfig(
          buttonText: isCurrentSub
              ? context.tr('change_subscription')
              : '${context.tr('subscribe_in')} ${context.tr('pro_package')}',
          gradientColors: const [Color(0xFFBD8F14), Color(0xFFF5C003)],
          isVertical: false,
          hasBorder: false,
          hasShadow: false,
        );

      case PackageType.elite:
        return _ButtonConfig(
          buttonText: isCurrentSub
              ? context.tr('change_subscription')
              : '${context.tr('subscribe_in')} ${context.tr('elite_package')}',
          gradientColors: const [Color(0xFF4BB8F9), Color(0xFF6284FF)],
          isVertical: true,
          hasBorder: true,
          hasShadow: true,
        );
    }
  }
}

class _ButtonConfig {
  final String buttonText;
  final List<Color> gradientColors;
  final bool isVertical;
  final bool hasBorder;
  final bool hasShadow;

  _ButtonConfig({
    required this.buttonText,
    required this.gradientColors,
    required this.isVertical,
    required this.hasBorder,
    required this.hasShadow,
  });
}
