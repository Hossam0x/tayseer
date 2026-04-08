import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/utils/styles.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';

class UserPackageActionButton extends StatelessWidget {
  final PackageType packageType;
  final VoidCallback onPressed;
  final bool isCurrentSub;

  const UserPackageActionButton({
    super.key,
    required this.packageType,
    required this.onPressed,
    this.isCurrentSub = false,
  });

  @override
  Widget build(BuildContext context) {
    if (packageType == PackageType.basic) {
      return _buildButton(
        context,
        buttonText: context.tr('continue_limited_account'),
        gradientColors: [AppColors.primary300, AppColors.primary500],
        isVertical: true,
        hasBorder: false,
        hasShadow: false,
      );
    }

    return BlocBuilder<UserPackagesCubit, UserPackagesState>(
      buildWhen: (prev, curr) => prev.subscriptions != curr.subscriptions,
      builder: (context, state) {
        final targetType = packageType == PackageType.pro ? 'gold' : 'ultra';
        final currency = getCurrency();

        // جيب أول sub من النوع المطلوب (monthly preferred)
        final subs = state.subscriptions
            .where((s) => s.subscriptionType == targetType)
            .toList();
        final monthlySub = subs.where((s) => s.isMonthly).firstOrNull;
        final anySub = monthlySub ?? subs.firstOrNull;

        final price = anySub?.price?.toString() ?? '';
        final subCurrency = anySub?.currency ?? currency;

        if (packageType == PackageType.pro) {
          final label = isCurrentSub
              ? context.tr('change_subscription')
              : price.isNotEmpty
              ? context
                    .tr('get_all_benefits_for')
                    .replaceFirst('{}', price)
                    .replaceFirst('{currency}', subCurrency)
              : '${context.tr('subscribe_in')} ${context.tr('pro_package')}';
          return _buildButton(
            context,
            buttonText: label,
            gradientColors: const [Color(0xFFBD8F14), Color(0xFFF5C003)],
            isVertical: false,
            hasBorder: false,
            hasShadow: false,
          );
        } else {
          final label = isCurrentSub
              ? context.tr('change_subscription')
              : price.isNotEmpty
              ? context
                    .tr('subscribe_vip_for')
                    .replaceFirst('{}', price)
                    .replaceFirst('{currency}', subCurrency)
              : '${context.tr('subscribe_in')} ${context.tr('elite_package')}';
          return _buildButton(
            context,
            buttonText: label,
            gradientColors: const [Color(0xFFFFBA40), Color(0xFFFF009F)],
            isVertical: true,
            hasBorder: true,
            hasShadow: true,
          );
        }
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String buttonText,
    required List<Color> gradientColors,
    required bool isVertical,
    required bool hasBorder,
    required bool hasShadow,
  }) {
    return Center(
      child: Container(
        width: 360.w,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11.r),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
            end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
          ),
          border: hasBorder
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
          boxShadow: hasShadow
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
            buttonText,
            style: Styles.textStyle18SemiBold.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
