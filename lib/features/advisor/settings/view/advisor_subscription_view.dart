import 'package:flutter/cupertino.dart';
import 'package:tayseer/features/advisor/settings/view_model/advisor_subscription_cubit.dart';
import 'package:tayseer/features/advisor/settings/view_model/packages_cubit.dart';
import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSubscriptionView extends StatelessWidget {
  const AdvisorSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvisorSubscriptionCubit, AdvisorSubscriptionState>(
      builder: (context, state) {
        final cubit = context.read<AdvisorSubscriptionCubit>();
        final pricing = cubit.getPricing();
        final packageTypeName = state.packageType == SelectedPackage.elite
            ? context.tr('elite_package')
            : context.tr('pro_package');

        return Scaffold(
          body: Stack(
            children: [
              // 1. Background Image
              Positioned.fill(
                child: Image.asset(
                  AssetsData.boostBackground,
                  fit: BoxFit.fill,
                ),
              ),
              // 2. Pink Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primaryPink.withOpacity(0.7),
                        AppColors.primary100,
                      ],
                      stops: [0.0, 0.4, 0.65],
                    ),
                  ),
                ),
              ),

              // 3. Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Header: Close Button
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, right: 10.w),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: AppColors.kWhiteColor,
                            size: 24.w,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            Gap(10.h),
                            // Logo
                            AppImage(
                              AssetsData.logoIcon,
                              width: 190.h,
                              color: AppColors.primary100,
                            ),
                            Gap(40.h),

                            // Titles
                            Text(
                              '${context.tr('subscribe_in')} $packageTypeName',
                              style: Styles.textStyle24Bold.copyWith(
                                color: AppColors.secondary800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Gap(8.h),
                            Text(
                              context.tr('subscribe_with_us_opportunity'),
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.secondary800,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            Gap(30.h),

                            // Duration Options
                            Column(
                              children: List.generate(pricing.length, (index) {
                                final item = pricing[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 25.h),
                                  child: _SubscriptionDurationCard(
                                    isSelected:
                                        state.selectedDurationIndex == index,
                                    data: item,
                                    onTap: () => cubit.selectDuration(index),
                                  ),
                                );
                              }),
                            ),

                            Gap(20.h),

                            // Wallet Toggle
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.tr('pay_from_wallet'),
                                      style: Styles.textStyle16Meduim.copyWith(
                                        color: AppColors.secondary800,
                                      ),
                                    ),
                                  ),
                                  Transform.scale(
                                    scaleX: -1,
                                    scaleY: 1,
                                    child: Transform.scale(
                                      scale:
                                          0.8, // Slightly smaller to fit the smaller container
                                      child: CupertinoSwitch(
                                        value: state.useWallet,
                                        activeColor: const Color(0xFFF06C88),
                                        trackColor: AppColors.dropDownArrow,
                                        onChanged: cubit.toggleWallet,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Gap(30.h),

                            // Pay Button
                            CustomBotton(
                              height: 54.h,
                              width: double.infinity,
                              title: context.tr('pay'),
                              onPressed: () {
                                // Payment logic
                              },
                              useGradient: true,
                            ),
                            Gap(30.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubscriptionDurationCard extends StatelessWidget {
  final bool isSelected;
  final SubscriptionPriceData data;
  final VoidCallback onTap;

  const _SubscriptionDurationCard({
    required this.isSelected,
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String currency = getCurrency();

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Card Container
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary200
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final String monthsText = context.tr(
                        data.months == 1
                            ? 'month'
                            : (data.months <= 10 ? 'months' : 'month'),
                      );
                      final String durationPart =
                          "${context.tr('for_duration')} ${data.months == 1 ? '' : '${data.months} '}$monthsText";
                      final String pricePart = "${data.price} $currency";
                      final String everyPart =
                          "${context.tr('every')} ${data.months == 1 ? '' : '${data.months} '}$monthsText";

                      return Text(
                        "${context.tr('subscription')} $durationPart , $pricePart $everyPart",
                        style: Styles.textStyle16SemiBold.copyWith(
                          color: isSelected
                              ? AppColors.blackColor
                              : AppColors.secondary700,
                        ),
                      );
                    },
                  ),
                ),
                Gap(12.w),

                // Radio Button Logic
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary600
                          : AppColors.secondary700,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Icon(
                            Icons.check,
                            size: 18.sp,
                            color: AppColors.primary600,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),

          // Discount Badge
          if (data.discount > 0)
            Positioned(
              top: -12.h,
              right: 25.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(245, 192, 3, 1),
                      Color.fromRGBO(228, 78, 108, 1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15.r),
                    bottomLeft: Radius.circular(15.r),
                    topLeft: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                ),
                child: Text(
                  context
                      .tr('discount_percent')
                      .replaceFirst('{}', '${data.discount}'),
                  style: Styles.textStyle12SemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
