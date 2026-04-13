import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/my_import.dart';

// ═══════════════════════════════════════
// MODEL
// ═══════════════════════════════════════
class PurchasePackage {
  final int count;
  final double pricePerUnit;
  final bool isMostPopular;
  final bool hasDiscount;
  final int? discountPercent;

  const PurchasePackage({
    required this.count,
    required this.pricePerUnit,
    this.isMostPopular = false,
    this.hasDiscount = false,
    this.discountPercent,
  });

  double get totalPrice => count * pricePerUnit;
}

enum PurchaseType { regards, likes }

// ═══════════════════════════════════════
// SHOW FUNCTIONS
// ═══════════════════════════════════════
void showRegardsPurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PurchaseSheet(type: PurchaseType.regards),
  );
}

void showLikesPurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PurchaseSheet(type: PurchaseType.likes),
  );
}

// ═══════════════════════════════════════
// SHEET
// ═══════════════════════════════════════
class _PurchaseSheet extends StatefulWidget {
  final PurchaseType type;
  const _PurchaseSheet({required this.type});

  @override
  State<_PurchaseSheet> createState() => _PurchaseSheetState();
}

class _PurchaseSheetState extends State<_PurchaseSheet> {
  int _selectedIndex = 1;
  bool _useWallet = true;
  late Timer _timer;
  int _remainingSeconds = 23 * 3600 + 5 * 60 + 40;

  final List<PurchasePackage> _regardsPackages = const [
    PurchasePackage(count: 1, pricePerUnit: 30),
    PurchasePackage(
      count: 5,
      pricePerUnit: 27,
      isMostPopular: true,
      hasDiscount: true,
      discountPercent: 20,
    ),
    PurchasePackage(count: 10, pricePerUnit: 25),
  ];

  final List<PurchasePackage> _likesPackages = const [
    PurchasePackage(count: 1, pricePerUnit: 5),
    PurchasePackage(
      count: 5,
      pricePerUnit: 4,
      isMostPopular: true,
      hasDiscount: true,
      discountPercent: 15,
    ),
    PurchasePackage(count: 10, pricePerUnit: 3),
  ];

  List<PurchasePackage> get _packages =>
      widget.type == PurchaseType.regards ? _regardsPackages : _likesPackages;

  bool get _isRegards => widget.type == PurchaseType.regards;

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
            _isRegards
                ? context.tr('regards_balance_finished')
                : context.tr('likes_balance_finished'),
            style: Styles.textStyle20Meduim.copyWith(
              color: AppColors.kscandryTextColor,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            _isRegards
                ? context.tr('regards_balance_finished_desc')
                : context.tr('likes_balance_finished_desc'),
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
          _buildWalletToggle(),
          SizedBox(height: 20.h),

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

  Widget _buildPackageCard(int index, PurchasePackage pkg) {
    final isSelected = _selectedIndex == index;
    final String itemLabel =
        _isRegards ? context.tr('regard') : context.tr('like');

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Directionality(
        // ✅ ثابت RTL دايمًا — مش بيتأثر باللغة
        textDirection: TextDirection.rtl,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ✅ الكارد
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                top: (pkg.hasDiscount && pkg.discountPercent != null)
                    ? 14.h
                    : 0,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary50 : Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary300
                      : AppColors.secondary100,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // ✅ العدد — يمين دايمًا (أول عنصر في RTL)
                  Text(
                    '${pkg.count} ',
                    style: Styles.textStyle32Meduim.copyWith(
                      color: AppColors.kscandryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // ✅ الاسم والسعر — وسط
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemLabel,
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // ✅ السعر LTR عشان الأرقام صح
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${pkg.totalPrice.toStringAsFixed(0)} EGP ${context.tr('per_unit')}',
                            style: Styles.textStyle12SemiBold.copyWith(
                              color: AppColors.secondary400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ most popular + checkmark — يسار دايمًا (آخر عنصر في RTL)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (pkg.isMostPopular)
                        Text(
                          context.tr('most_popular'),
                          style: Styles.textStyle14SemiBold.copyWith(
                            color: AppColors.secondary700,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary400
                                : AppColors.secondary300,
                            width: 2,
                          ),
                          color: isSelected
                              ? AppColors.primary400
                              : Colors.white,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.w,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ Discount badge — يمين دايمًا بسبب RTL الثابت
            if (pkg.hasDiscount && pkg.discountPercent != null)
              Positioned(
                top: 0,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEB7A91),
                        Color.fromRGBO(245, 192, 3, 1),
                      ],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20.r),
                      topLeft: Radius.circular(6.r),
                      bottomRight: Radius.circular(6.r),
                      bottomLeft: Radius.circular(20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEB7A91).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    context
                        .tr('save_percent')
                        .replaceAll('{percent}', '${pkg.discountPercent}'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
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