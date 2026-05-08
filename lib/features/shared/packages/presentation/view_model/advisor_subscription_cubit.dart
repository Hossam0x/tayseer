import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'packages_cubit.dart';

enum AdvisorSubStatus { initial, purchasing, success, canceled, error }

class AdvisorSubscriptionState extends Equatable {
  final int selectedDurationIndex;
  final SelectedPackage packageType;
  final AdvisorSubStatus status;
  final String? error;

  const AdvisorSubscriptionState({
    this.selectedDurationIndex = 0,
    required this.packageType,
    this.status = AdvisorSubStatus.initial,
    this.error,
  });

  AdvisorSubscriptionState copyWith({
    int? selectedDurationIndex,
    SelectedPackage? packageType,
    AdvisorSubStatus? status,
    String? error,
  }) {
    return AdvisorSubscriptionState(
      selectedDurationIndex:
          selectedDurationIndex ?? this.selectedDurationIndex,
      packageType: packageType ?? this.packageType,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    selectedDurationIndex,
    packageType,
    status,
    error,
  ];
}

class AdvisorSubscriptionCubit extends Cubit<AdvisorSubscriptionState> {
  final IAPService _iapService;

  AdvisorSubscriptionCubit(SelectedPackage packageType, this._iapService)
    : super(AdvisorSubscriptionState(packageType: packageType));

  /// ترتيب المدة: weekly=0, monthly=1, threemonths=2
  int _durationWeight(NewAdvisorSubModel s) {
    switch (s.subscriptionDurationType) {
      case 'weekly':
        return 0;
      case 'monthly':
        return 1;
      case 'threemonths':
        return 2;
      default:
        return -1;
    }
  }

  /// يرجع الـ subscriptions المناسبة للباقة مرتبة تصاعدياً (weekly → monthly → threemonths)
  List<NewAdvisorSubModel> getSubscriptionsForPackage(
    List<NewAdvisorSubModel> allSubs,
  ) {
    final targetType = state.packageType == SelectedPackage.elite
        ? 'ultra'
        : 'gold';
    final filtered = allSubs
        .where((s) => s.subscriptionType == targetType)
        .toList();
    filtered.sort((a, b) => _durationWeight(a).compareTo(_durationWeight(b)));
    return filtered;
  }

  /// يرجع الـ current sub لو موجودة
  NewAdvisorSubModel? getCurrentSub(List<NewAdvisorSubModel> allSubs) {
    return getSubscriptionsForPackage(
      allSubs,
    ).where((s) => s.isCurrentSub).firstOrNull;
  }

  /// يرجع أول upgrade متاح — يعني أول sub مدتها أكبر من الـ current فقط
  NewAdvisorSubModel? getUpgradeSub(List<NewAdvisorSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    if (current == null) return null;
    final currentWeight = _durationWeight(current);
    // upgrade = أي sub مدتها أكبر من الـ current (مش أقل أو مساوية)
    return subs
        .where((s) => !s.isCurrentSub && _durationWeight(s) > currentWeight)
        .firstOrNull;
  }

  /// يرجع أول downgrade متاح — مدتها أقل من الـ current
  /// متاح فقط لو الاشتراك الحالي ملغي auto-renew (isCancelled)
  NewAdvisorSubModel? getDowngradeSub(List<NewAdvisorSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    if (current == null) return null;
    // downgrade متاح فقط لو الاشتراك الحالي ملغي auto-renew
    if (!current.isCancelled) return null;
    final currentWeight = _durationWeight(current);
    return subs
        .where((s) => !s.isCurrentSub && _durationWeight(s) < currentWeight)
        .lastOrNull; // أقرب مدة أقل
  }

  /// أول ما تيجي البيانات — يختار الـ monthly تلقائياً (Most Popular)
  /// لو مفيش monthly يختار الأولى
  void initSelection(List<NewAdvisorSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;
    final currentIndex = subs.indexWhere((s) => s.isCurrentSub);
    if (currentIndex == -1) {
      // اختار الـ monthly (index = 1) لو موجود، غير كده الأولى
      final monthlyIndex = subs.indexWhere((s) => s.isMonthly);
      emit(
        state.copyWith(
          selectedDurationIndex: monthlyIndex != -1 ? monthlyIndex : 0,
        ),
      );
    }
    // لو في current sub مش محتاج نعمل حاجة — الـ UI هيعرض الـ upgrade مباشرة
  }

  /// للحالة اللي مفيش current sub — اختيار من الكارتين
  void selectDuration(int index, List<NewAdvisorSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    if (index >= subs.length) return;
    if (subs[index].isCurrentSub) return;
    emit(state.copyWith(selectedDurationIndex: index));
  }

  void resetStatus() => emit(state.copyWith(status: AdvisorSubStatus.initial));

  Future<void> purchaseSubscription(List<NewAdvisorSubModel> allSubs) async {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;

    // ── Step 1: تحديد الـ target subscription ────────────────────────────
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final NewAdvisorSubModel targetSub;

    if (current != null) {
      // ✅ لو الاشتراك الحالي نشط (مش ملغي) → upgrade فقط
      if (current.isActiveInApple) {
        final upgrade = getUpgradeSub(allSubs);
        if (upgrade == null) {
          log('[AdvisorSub] ⚠️ No upgrade available — current is active');
          return;
        }
        targetSub = upgrade;
        log(
          '[AdvisorSub] 📈 UPGRADE: ${current.subscriptionDurationType} → ${targetSub.subscriptionDurationType}',
        );
      } else {
        // ✅ الاشتراك ملغي auto-renew → يمكن upgrade أو downgrade
        final upgrade = getUpgradeSub(allSubs);
        final downgrade = getDowngradeSub(allSubs);

        if (upgrade != null) {
          targetSub = upgrade;
          log(
            '[AdvisorSub] 📈 UPGRADE (cancelled sub): ${current.subscriptionDurationType} → ${targetSub.subscriptionDurationType}',
          );
        } else if (downgrade != null) {
          targetSub = downgrade;
          log(
            '[AdvisorSub] 📉 DOWNGRADE: ${current.subscriptionDurationType} → ${targetSub.subscriptionDurationType}',
          );
        } else {
          log('[AdvisorSub] ⚠️ No change available');
          return;
        }
      }
    } else {
      // ✅ مفيش اشتراك حالي → اشتري الـ selected
      if (state.selectedDurationIndex >= subs.length) return;
      targetSub = subs[state.selectedDurationIndex];
      log(
        '[AdvisorSub] 🆕 NEW SUBSCRIPTION: ${targetSub.subscriptionDurationType}',
      );
    }

    // ── Step 2: التحقق من الـ product ID ──────────────────────────────────
    final productId = targetSub.appleProductId;
    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: AdvisorSubStatus.error,
          error: 'purchase_invalid_product',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AdvisorSubStatus.purchasing));
    unawaited(_iapService.init());

    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      // ── Step 1: قراءة الـ uuid من الكاش ──────────────────────────────────
      final uuid = CachNetwork.getStringData(key: kUuid);

      log('[AdvisorSub] ════════════════════════════════════════');
      log('[AdvisorSub] 🛒 PURCHASE FLOW START');
      log('[AdvisorSub]   productId      : $productId');
      log('[AdvisorSub]   platform       : $platform');
      log('[AdvisorSub]   subscriptionId : ${targetSub.id}');
      log(
        '[AdvisorSub]   target sub     : ${targetSub.subscriptionDurationType}',
      );
      log(
        '[AdvisorSub]   current sub    : ${current?.subscriptionDurationType ?? "none"}',
      );
      log(
        '[AdvisorSub]   is active      : ${current?.isActiveInApple ?? false}',
      );
      log('[AdvisorSub]   is cancelled   : ${current?.isCancelled ?? false}');
      log('[AdvisorSub] ────────────────────────────────────────');
      log(
        '[AdvisorSub] 🆔 uuid from cache  : ${uuid.isNotEmpty ? uuid : "⚠️ EMPTY — uuid not cached yet"}',
      );
      log('[AdvisorSub] 📲 applicationUserName → Apple: $uuid');
      log('[AdvisorSub] ════════════════════════════════════════');

      if (uuid.isEmpty) {
        emit(
          state.copyWith(
            status: AdvisorSubStatus.error,
            error: 'purchase_user_data_missing',
          ),
        );
        return;
      }

      // ── Step 2: Apple IAP ─────────────────────────────────────────────────
      final purchase = await _iapService.buyProduct(
        productId,
        uniqueNumber: uuid,
      );

      log('[AdvisorSub] ✅ Apple purchase success:');
      log('[AdvisorSub]   purchaseID (transactionId): ${purchase.purchaseID}');
      log('[AdvisorSub]   productID                 : ${purchase.productID}');
      log(
        '[AdvisorSub]   transactionDate           : ${purchase.transactionDate}',
      );
      log('[AdvisorSub]   status                    : ${purchase.status}');

      // ── Step 3: Success ───────────────────────────────────────────────────
      // Apple بتكلم الباك مباشرة عن طريق server-to-server notifications
      // transfer-subscription بتتبعت بس في الـ restore flow مش هنا
      final newType = targetSub.subscriptionType;
      SubscriptionEventBus.instance.fire(
        SubscriptionChangedEvent(subscriptionType: newType),
      );
      emit(state.copyWith(status: AdvisorSubStatus.success));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(
        state.copyWith(
          status: err.isCanceled
              ? AdvisorSubStatus.canceled
              : AdvisorSubStatus.error,
          error: err.isCanceled ? null : err.messageKey,
        ),
      );
    }
  }
}
