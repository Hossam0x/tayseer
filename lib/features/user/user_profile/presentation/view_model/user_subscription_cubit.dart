import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';

enum UserSubStatus { initial, purchasing, success, canceled, error }

class UserSubscriptionState extends Equatable {
  final int selectedDurationIndex;
  final SelectedPackage packageType;
  final UserSubStatus status;
  final String? error;

  const UserSubscriptionState({
    this.selectedDurationIndex = 0,
    required this.packageType,
    this.status = UserSubStatus.initial,
    this.error,
  });

  UserSubscriptionState copyWith({
    int? selectedDurationIndex,
    SelectedPackage? packageType,
    UserSubStatus? status,
    String? error,
  }) {
    return UserSubscriptionState(
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

class UserSubscriptionCubit extends Cubit<UserSubscriptionState> {
  final IAPService _iapService;

  UserSubscriptionCubit(SelectedPackage packageType, this._iapService)
    : super(UserSubscriptionState(packageType: packageType));

  List<NewUserSubModel> getSubscriptionsForPackage(
    List<NewUserSubModel> allSubs,
  ) {
    final targetType = state.packageType == SelectedPackage.elite
        ? 'ultra'
        : 'gold';
    final filtered = allSubs
        .where((s) => s.subscriptionType == targetType)
        .toList();
    // Sort: weekly first, then monthly, then threeMonths
    filtered.sort((a, b) {
      final order = {'weekly': 0, 'monthly': 1, 'threemonths': 2};
      return (order[a.subscriptionDurationType] ?? 3).compareTo(
        order[b.subscriptionDurationType] ?? 3,
      );
    });
    return filtered;
  }

  NewUserSubModel? getCurrentSub(List<NewUserSubModel> allSubs) {
    return getSubscriptionsForPackage(
      allSubs,
    ).where((s) => s.isCurrentSub).firstOrNull;
  }

  int _durationWeight(NewUserSubModel s) {
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

  NewUserSubModel? getUpgradeSub(List<NewUserSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    if (current == null) return null;
    final currentWeight = _durationWeight(current);
    // upgrade = أي sub مدتها أكبر من الـ current فقط
    return subs
        .where((s) => !s.isCurrentSub && _durationWeight(s) > currentWeight)
        .firstOrNull;
  }

  /// downgrade متاح فقط لو الاشتراك الحالي ملغي auto-renew
  NewUserSubModel? getDowngradeSub(List<NewUserSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    if (current == null) return null;
    if (!current.isCancelled) return null;
    final currentWeight = _durationWeight(current);
    return subs
        .where((s) => !s.isCurrentSub && _durationWeight(s) < currentWeight)
        .lastOrNull;
  }

  /// أول ما تيجي البيانات — يختار الـ monthly تلقائياً (Most Popular)
  /// لو مفيش monthly يختار الأولى
  void initSelection(List<NewUserSubModel> allSubs) {
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
  }

  void selectDuration(int index, List<NewUserSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    if (index >= subs.length) return;
    if (subs[index].isCurrentSub) return;
    emit(state.copyWith(selectedDurationIndex: index));
  }

  void resetStatus() => emit(state.copyWith(status: UserSubStatus.initial));

  Future<void> purchaseSubscription(List<NewUserSubModel> allSubs) async {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;

    // ── Step 1: تحديد الـ target subscription ────────────────────────────
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final NewUserSubModel targetSub;

    if (current != null) {
      if (current.isActiveInApple) {
        // اشتراك نشط → upgrade فقط
        final upgrade = getUpgradeSub(allSubs);
        if (upgrade == null) {
          log('[UserSub] ⚠️ No upgrade available — current is active in Apple');
          return;
        }
        targetSub = upgrade;
        log(
          '[UserSub] 📈 UPGRADE: ${current.subscriptionDurationType} → ${targetSub.subscriptionDurationType}',
        );
      } else {
        // اشتراك ملغي auto-renew → upgrade أو downgrade
        final upgrade = getUpgradeSub(allSubs);
        final downgrade = getDowngradeSub(allSubs);
        if (upgrade != null) {
          targetSub = upgrade;
          log(
            '[UserSub] 📈 UPGRADE (cancelled): ${current.subscriptionDurationType} → ${targetSub.subscriptionDurationType}',
          );
        } else if (downgrade != null) {
          targetSub = downgrade;
          log(
            '[UserSub] 📉 DOWNGRADE: ${current.subscriptionDurationType} → ${targetSub.subscriptionDurationType}',
          );
        } else {
          log('[UserSub] ⚠️ No change available');
          return;
        }
      }
    } else {
      if (state.selectedDurationIndex >= subs.length) return;
      targetSub = subs[state.selectedDurationIndex];
      log(
        '[UserSub] 🆕 NEW SUBSCRIPTION: ${targetSub.subscriptionDurationType}',
      );
    }

    // ── Step 2: التحقق من الـ product ID ──────────────────────────────────
    final productId = targetSub.appleProductId;
    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: UserSubStatus.error,
          error: 'purchase_invalid_product',
        ),
      );
      return;
    }

    emit(state.copyWith(status: UserSubStatus.purchasing));
    unawaited(_iapService.init());

    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      // ── Step 1: قراءة الـ uuid من الكاش ──────────────────────────────────
      final uuid = CachNetwork.getStringData(key: kUuid);

      log('[UserSub] ════════════════════════════════════════');
      log('[UserSub] 🛒 PURCHASE FLOW START');
      log('[UserSub]   productId      : $productId');
      log('[UserSub]   platform       : $platform');
      log('[UserSub]   subscriptionId : ${targetSub.id}');
      log('[UserSub]   target sub     : ${targetSub.subscriptionDurationType}');
      log(
        '[UserSub]   current sub    : ${current?.subscriptionDurationType ?? "none"}',
      );
      log('[UserSub]   is active      : ${current?.isActiveInApple ?? false}');
      log('[UserSub]   is cancelled   : ${current?.isCancelled ?? false}');
      log('[UserSub] ────────────────────────────────────────');
      log(
        '[UserSub] 🆔 uuid from cache  : ${uuid.isNotEmpty ? uuid : "⚠️ EMPTY — uuid not cached yet"}',
      );
      log('[UserSub] 📲 applicationUserName → Apple: $uuid');
      log('[UserSub] ════════════════════════════════════════');

      if (uuid.isEmpty) {
        emit(
          state.copyWith(
            status: UserSubStatus.error,
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

      log('[UserSub] ✅ Apple purchase success:');
      log('[UserSub]   purchaseID (transactionId): ${purchase.purchaseID}');
      log('[UserSub]   productID                 : ${purchase.productID}');
      log(
        '[UserSub]   transactionDate           : ${purchase.transactionDate}',
      );
      log('[UserSub]   status                    : ${purchase.status}');

      // ── Step 3: Success ───────────────────────────────────────────────────
      // Apple بتكلم الباك مباشرة عن طريق server-to-server notifications
      // transfer-subscription بتتبعت بس في الـ restore flow مش هنا
      SubscriptionEventBus.instance.fire(
        SubscriptionChangedEvent(subscriptionType: targetSub.subscriptionType),
      );
      emit(state.copyWith(status: UserSubStatus.success));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(
        state.copyWith(
          status: err.isCanceled ? UserSubStatus.canceled : UserSubStatus.error,
          error: err.isCanceled ? null : err.messageKey,
        ),
      );
    }
  }
}
