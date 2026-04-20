import 'dart:async';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/user/marriage/model/regards_package_model.dart';
import 'package:tayseer/features/user/marriage/view_model/regards_packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_subscription_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/regards_package_cubit/regards_package_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/regards_package_cubit/regards_package_state.dart';
import 'package:tayseer/my_import.dart';

// ═══════════════════════════════════════
// MODEL
// ═══════════════════════════════════════
class PurchasePackage {
  final String id;
  final String appleProductId;
  final int count;
  final double price;
  final double priceForOne;
  final String currency;
  final bool isMostPopular;
  final bool hasDiscount;
  final int? discountPercent;
  final String? label; // used for gold: 'أسبوعي' / 'شهري'

  const PurchasePackage({
    required this.id,
    required this.appleProductId,
    required this.count,
    required this.price,
    this.priceForOne = 0,
    this.currency = 'EGP',
    this.isMostPopular = false,
    this.hasDiscount = false,
    this.discountPercent,
    this.label,
  });

  static List<PurchasePackage> fromApiPackages(
    List<RegardsPackageModel> packages,
  ) {
    final sorted = [...packages]..sort((a, b) => a.amount.compareTo(b.amount));
    return sorted.asMap().entries.map((e) {
      final i = e.key;
      final pkg = e.value;
      final isMid = i == 1 && sorted.length >= 3;
      return PurchasePackage(
        id: pkg.id,
        appleProductId: pkg.appleProductId,
        count: pkg.amount,
        price: pkg.price,
        priceForOne: pkg.priceForOne,
        currency: pkg.currency,
        isMostPopular: isMid,
        hasDiscount: isMid,
        discountPercent: isMid ? 20 : null,
      );
    }).toList();
  }

  static List<PurchasePackage> fromGoldSubs(
    List<NewUserSubModel> subs,
    BuildContext context,
  ) {
    final gold = subs.where((s) => s.subscriptionType == 'gold').toList();
    gold.sort((a, b) {
      const order = {'weekly': 0, 'monthly': 1, 'threemonths': 2};
      return (order[a.subscriptionDurationType] ?? 3)
          .compareTo(order[b.subscriptionDurationType] ?? 3);
    });
    return gold.asMap().entries.map((e) {
      final i = e.key;
      final sub = e.value;
      final isMid = i == 1 && gold.length >= 3;
      final labelKey = sub.isMonthly
          ? 'monthly'
          : sub.isWeekly
              ? 'weekly'
              : 'three_months';
      return PurchasePackage(
        id: sub.id,
        appleProductId: sub.appleProductId,
        count: sub.numberOfLikes,
        price: (sub.price ?? 0).toDouble(),
        currency: sub.currency ?? 'EGP',
        isMostPopular: isMid,
        hasDiscount: isMid,
        discountPercent: isMid ? 20 : null,
        label: context.tr(labelKey),
      );
    }).toList();
  }
}

enum PurchaseType { regards, likes, gold }

// ═══════════════════════════════════════
// SHOW FUNCTIONS
// ═══════════════════════════════════════
void showRegardsPurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<RegardsPackagesCubit>()..fetchPackages(),
        ),
        BlocProvider(create: (_) => getIt<RegardsPackagePurchaseCubit>()),
      ],
      child: const _PurchaseSheet(type: PurchaseType.regards),
    ),
  );
}

void showLikesPurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PurchaseSheet(type: PurchaseType.likes),
  );
}

void showGoldPurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserSubscriptionCubit(
            SelectedPackage.pro,
            getIt<IAPService>(),
            getIt<ApiService>(),
          ),
        ),
        BlocProvider(
          create: (_) => getIt<UserPackagesCubit>()..getPackages(),
        ),
      ],
      child: const _PurchaseSheet(type: PurchaseType.gold),
    ),
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
  int _selectedIndex = 0;
  bool _useWallet = true;
  late Timer _timer;
  int _remainingSeconds = 0;

  // ✅ countdown لإظهار زر الإغلاق
  int _closeCountdown = 5;
  bool _canClose = false;

  bool get _isRegards => widget.type == PurchaseType.regards;
  bool get _isGold => widget.type == PurchaseType.gold;

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

    // ✅ countdown لزر الإغلاق
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_closeCountdown > 0) {
        setState(() => _closeCountdown--);
      } else {
        setState(() => _canClose = true);
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _initCountdown(DateTime? incrementAt) {
    if (incrementAt == null) return;
    final diff = incrementAt.difference(DateTime.now());
    if (diff.isNegative) return;
    if (_remainingSeconds == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _remainingSeconds = diff.inSeconds);
      });
    }
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
  String get _hours => _pad(_remainingSeconds ~/ 3600);
  String get _minutes => _pad((_remainingSeconds % 3600) ~/ 60);
  String get _seconds => _pad(_remainingSeconds % 60);

  void _onPayRegards(BuildContext context, List<PurchasePackage> packages) {
    if (packages.isEmpty) return;
    final idx = _selectedIndex.clamp(0, packages.length - 1);
    final selected = packages[idx];
    final rawPackage = RegardsPackageModel(
      id: selected.id,
      appleProductId: selected.appleProductId,
      amount: selected.count,
      price: selected.price,
      currency: selected.currency,
      priceForOne: selected.priceForOne,
    );
    context.read<RegardsPackagePurchaseCubit>().purchasePackage(rawPackage);
  }

  void _onPayGold(BuildContext context, List<NewUserSubModel> allSubs) {
    context.read<UserSubscriptionCubit>().purchaseSubscription(allSubs);
  }

  @override
  Widget build(BuildContext context) {
    if (_isGold) {
      return _buildGoldSheet(context);
    }

    return BlocListener<RegardsPackagePurchaseCubit, RegardsPackagePurchaseState>(
      listener: (context, state) {
        if (state.status == RegardsPackagePurchaseStatus.success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('purchase_success'), isSuccess: true),
          );
        } else if (state.status == RegardsPackagePurchaseStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: state.error!, isError: true),
          );
          context.read<RegardsPackagePurchaseCubit>().resetStatus();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: _isRegards
            ? BlocBuilder<RegardsPackagesCubit, RegardsPackagesState>(
                builder: (context, state) {
                  if (state.regardsIncrementAt != null) {
                    _initCountdown(state.regardsIncrementAt);
                  }
                  final packages = state.status == CubitStates.success
                      ? PurchasePackage.fromApiPackages(state.packages)
                      : <PurchasePackage>[];
                  return _buildContent(
                    context,
                    packages: packages,
                    isLoading: state.status == CubitStates.loading,
                    onPay: () => _onPayRegards(context, packages),
                  );
                },
              )
            : _buildContent(context, packages: [], isLoading: false, onPay: () {}),
      ),
    );
  }

  Widget _buildGoldSheet(BuildContext context) {
    return BlocConsumer<UserSubscriptionCubit, UserSubscriptionState>(
      listener: (context, state) {
        if (state.status == UserSubStatus.success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: context.tr('purchase_success'), isSuccess: true),
          );
        } else if (state.status == UserSubStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(context, text: state.error!, isError: true),
          );
          context.read<UserSubscriptionCubit>().resetStatus();
        } else if (state.status == UserSubStatus.canceled) {
          context.read<UserSubscriptionCubit>().resetStatus();
        }
      },
      builder: (context, subState) {
        return BlocBuilder<UserPackagesCubit, UserPackagesState>(
          builder: (context, packagesState) {
            final isLoading = packagesState.isLoading;
            final allSubs = packagesState.subscriptions;
            final packages = isLoading
                ? <PurchasePackage>[]
                : PurchasePackage.fromGoldSubs(allSubs, context);
            final isPurchasing = subState.status == UserSubStatus.purchasing;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
              child: _buildContent(
                context,
                packages: packages,
                isLoading: isLoading,
                isPurchasing: isPurchasing,
                onPay: () => _onPayGold(context, allSubs),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required List<PurchasePackage> packages,
    required bool isLoading,
    bool isPurchasing = false,
    required VoidCallback onPay,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ Handle + زر الإغلاق
        Row(
          children: [
            // زر الإغلاق أو العداد
            SizedBox(
              width: 36.w,
              height: 36.w,
              child: _canClose
                  ? GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: 18.w, color: AppColors.secondary600),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$_closeCountdown',
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.secondary200,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 36.w), // balance
          ],
        ),
        SizedBox(height: 16.h),

        // Title
        Text(
          _isRegards
              ? context.tr('regards_balance_finished')
              : _isGold
                  ? context.tr('likes_balance_finished')
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
              : _isGold
                  ? context.tr('likes_balance_finished_desc')
                  : context.tr('likes_balance_finished_desc'),
          style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),

        if (_remainingSeconds > 0) ...[
          _buildCountdown(),
          SizedBox(height: 20.h),
        ],

        if (isLoading)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const CircularProgressIndicator(),
          )
        else ...[
          ...packages.asMap().entries.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _buildPackageCard(e.key, e.value),
            ),
          ),
        ],

        SizedBox(height: 12.h),
        SizedBox(height: 20.h),
        CustomBotton(
          title: isPurchasing ? '' : context.tr('pay'),
          height: 54.h,
          width: double.infinity,
          useGradient: true,
          isLoading: isPurchasing,
          onPressed: isPurchasing || packages.isEmpty ? null : onPay,
        ),
      ],
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
        style: Styles.textStyle24SemiBold.copyWith(color: AppColors.kscandryTextColor),
      ),
    );
  }

  Widget _separator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Text(
        ':',
        style: Styles.textStyle24SemiBold.copyWith(color: AppColors.kscandryTextColor),
      ),
    );
  }

  Widget _buildPackageCard(int index, PurchasePackage pkg) {
    final isSelected = _selectedIndex == index;
    final String itemLabel = _isRegards
        ? context.tr('regard')
        : _isGold
            ? (pkg.label ?? context.tr('gold_package'))
            : context.tr('like');

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                top: (pkg.hasDiscount && pkg.discountPercent != null) ? 14.h : 0,
              ),
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
                children: [
                  if (!_isGold)
                    Text(
                      '${pkg.count} ',
                      style: Styles.textStyle32Meduim.copyWith(
                        color: AppColors.kscandryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemLabel,
                          style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
                        ),
                        SizedBox(height: 4.h),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${pkg.price.toStringAsFixed(0)} ${pkg.currency}',
                            style: Styles.textStyle12SemiBold.copyWith(
                              color: AppColors.secondary400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            color: isSelected ? AppColors.primary400 : AppColors.secondary300,
                            width: 2,
                          ),
                          color: isSelected ? AppColors.primary400 : Colors.white,
                        ),
                        child: isSelected
                            ? Icon(Icons.check, size: 14.w, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (pkg.hasDiscount && pkg.discountPercent != null)
              Positioned(
                top: 0,
                right: 12.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEB7A91), Color.fromRGBO(245, 192, 3, 1)],
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
                    context.tr('save_percent').replaceAll('{percent}', '${pkg.discountPercent}'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

}

// ═══════════════════════════════════════
// REGARD INPUT SHEET (standalone)
// ═══════════════════════════════════════
void showRegardInputSheet(
  BuildContext context, {
  required String personId,
  required String personName,
  required void Function(String text) onSend,
}) {
  final controller = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 20.w,
          right: 20.w,
          top: 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$personName ${context.tr('messge_profil_title')}',
              style: Styles.textStyle14Bold,
            ),
            Gap(10.h),
            TextField(
              controller: controller,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                fillColor: HexColor('f9f8ec'),
                filled: true,
                hintText: context.tr('type_your_message'),
                hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Gap(16.h),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                final enabled = value.text.trim().isNotEmpty;
                return CustomBotton(
                  backGroundcolor: AppColors.kgreyColor,
                  useGradient: enabled,
                  title: context.tr('send_reply'),
                  onPressed: enabled
                      ? () {
                          Navigator.pop(sheetContext);
                          onSend(value.text.trim());
                        }
                      : null,
                );
              },
            ),
            Gap(20.h),
          ],
        ),
      );
    },
  );
}
