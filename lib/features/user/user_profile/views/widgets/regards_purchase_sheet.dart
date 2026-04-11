import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/my_import.dart';

class RegardPackage {
  final int count;
  final double pricePerUnit;
  final bool isMostPopular;
  final bool hasDiscount;
  final int? discountPercent;

  const RegardPackage({
    required this.count,
    required this.pricePerUnit,
    this.isMostPopular = false,
    this.hasDiscount = false,
    this.discountPercent,
  });

  double get totalPrice => count * pricePerUnit;
}

void showRegardsPurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RegardsPurchaseSheet(),
  );
}

class _RegardsPurchaseSheet extends StatefulWidget {
  const _RegardsPurchaseSheet();

  @override
  State<_RegardsPurchaseSheet> createState() => _RegardsPurchaseSheetState();
}

class _RegardsPurchaseSheetState extends State<_RegardsPurchaseSheet> {
  int _selectedIndex = 1;
  bool _useWallet = true;
  late Timer _timer;
  int _remainingSeconds = 23 * 3600 + 5 * 60 + 40;

  final List<RegardPackage> _packages = const [
    RegardPackage(count: 1, pricePerUnit: 30),
    RegardPackage(
      count: 5,
      pricePerUnit: 27,
      isMostPopular: true,
      hasDiscount: true,
      discountPercent: 20,
    ),
    RegardPackage(count: 10, pricePerUnit: 25),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String get _hours => _pad(_remainingSeconds ~/ 3600);
  String get _minutes => _pad((_remainingSeconds % 3600) ~/ 60);
  String get _seconds => _pad(_remainingSeconds % 60);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            context.tr('regards_balance_finished'),
            style: Styles.textStyle20Meduim.copyWith(
              color: AppColors.kscandryTextColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            context.tr('regards_balance_finished_desc'),
            style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),

          // Countdown
          _buildCountdown(),
          SizedBox(height: 20.h),

          // Packages
          ..._packages.asMap().entries.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildPackageCard(e.key, e.value),
            ),
          ),

          SizedBox(height: 12.h),

          // Wallet toggle
          _buildWalletToggle(),
          SizedBox(height: 20.h),

          // Pay button
          CustomBotton(
            title: context.tr('pay'),
            height: 54.h,
            width: double.infinity,
            useGradient: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _timeBox(_hours),
        _separator(),
        _timeBox(_minutes),
        _separator(),
        _timeBox(_seconds),
      ],
    );
  }

  Widget _timeBox(String value) {
    return Container(
      width: 56.w,
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        value,
        style: Styles.textStyle24SemiBold.copyWith(
          color: AppColors.kscandryTextColor,
        ),
      ),
    );
  }

  Widget _separator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Text(
        ':',
        style: Styles.textStyle24SemiBold.copyWith(
          color: AppColors.kscandryTextColor,
        ),
      ),
    );
  }

  Widget _buildPackageCard(int index, RegardPackage pkg) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary50 : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? AppColors.primary300 : AppColors.secondary100,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          textDirection: Localizations.localeOf(context).languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          children: [
            // Radio
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary400
                      : AppColors.secondary300,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary400 : Colors.white,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.w, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),

            // Labels
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (pkg.hasDiscount && pkg.discountPercent != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      margin: EdgeInsets.only(bottom: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        context
                            .tr('save_percent')
                            .replaceAll('{percent}', '${pkg.discountPercent}'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (pkg.isMostPopular)
                    Text(
                      context.tr('most_popular'),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.secondary400,
                      ),
                    ),
                ],
              ),
            ),

            // Price info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${pkg.count} ',
                        style: Styles.textStyle24SemiBold.copyWith(
                          color: AppColors.kscandryTextColor,
                        ),
                      ),
                      TextSpan(
                        text: context.tr('regard'),
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${pkg.totalPrice.toStringAsFixed(0)} EGP ${context.tr('per_unit')}',
                  style: Styles.textStyle12SemiBold.copyWith(
                    color: AppColors.secondary400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletToggle() {
    return Row(
      children: [
        Transform.scale(
          scale: 0.85,
          child: Switch(
            value: _useWallet,
            activeTrackColor: AppColors.primary400,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.secondary200,
            onChanged: (val) => setState(() => _useWallet = val),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          context.tr('pay_from_wallet'),
          style: Styles.textStyle14.copyWith(color: AppColors.secondary700),
        ),
      ],
    );
  }
}
