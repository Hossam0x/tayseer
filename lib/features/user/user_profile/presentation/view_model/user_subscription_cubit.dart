import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/services/paymob_service/paymob_webview_screen.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';
import 'package:tayseer/features/advisor/membership/data/models/restore_purchase_result.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';

enum UserSubStatus {
  initial,
  purchasing,
  success,
  canceled,
  error,
  needsTransfer, // ✅ Apple purchase نجح لكن الاشتراك على account تاني
  profileIncomplete, // ✅ الـ profile ناقص (phoneRequired)
}

class UserSubscriptionState extends Equatable {
  final int selectedDurationIndex;
  final SelectedPackage packageType;
  final UserSubStatus status;
  final String? error;
  final String? transferPurchaseId;
  final bool saveCard; // ✅ Android: هل يحفظ الكارت للـ auto-renew

  const UserSubscriptionState({
    this.selectedDurationIndex = 0,
    required this.packageType,
    this.status = UserSubStatus.initial,
    this.error,
    this.transferPurchaseId,
    this.saveCard = false,
  });

  UserSubscriptionState copyWith({
    int? selectedDurationIndex,
    SelectedPackage? packageType,
    UserSubStatus? status,
    String? error,
    String? transferPurchaseId,
    bool? saveCard,
  }) {
    return UserSubscriptionState(
      selectedDurationIndex:
          selectedDurationIndex ?? this.selectedDurationIndex,
      packageType: packageType ?? this.packageType,
      status: status ?? this.status,
      error: error,
      transferPurchaseId: transferPurchaseId ?? this.transferPurchaseId,
      saveCard: saveCard ?? this.saveCard,
    );
  }

  @override
  List<Object?> get props => [
    selectedDurationIndex,
    packageType,
    status,
    error,
    transferPurchaseId,
    saveCard,
  ];
}

class UserSubscriptionCubit extends Cubit<UserSubscriptionState> {
  final IAPService _iapService;
  final MembershipRepository _membershipRepository;

  UserSubscriptionCubit(
    SelectedPackage packageType,
    this._iapService,
    this._membershipRepository,
  ) : super(UserSubscriptionState(packageType: packageType));

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
          emit(
            state.copyWith(
              status: UserSubStatus.error,
              error: 'already_on_highest_plan',
            ),
          );
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
          emit(
            state.copyWith(
              status: UserSubStatus.error,
              error: 'already_on_highest_plan',
            ),
          );
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

    // تهيئة الـ IAP service قبل الشراء — iOS فقط
    // على Android الـ Paymob flow مش محتاج IAPService
    if (Platform.isIOS) {
      try {
        await _iapService.init();
      } catch (e) {
        log('[UserSub] ❌ IAP init failed: $e');
        emit(
          state.copyWith(
            status: UserSubStatus.error,
            error: 'store_unavailable',
          ),
        );
        return;
      }
    }

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
      log('[UserSub] 📤 Will call initiate-purchase next...');
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

      // ── Step 2: Initiate purchase on backend → get pendingId ──────────────
      log('[UserSub] 📤 Calling /iap/initiate-purchase...');
      final initiateResult = await _membershipRepository.initiatePurchase(
        productId: productId,
        platform: platform,
      );
      if (isClosed) return;

      final String pendingId;
      final initiateCheck = initiateResult.fold<String?>(
        (f) {
          log('[UserSub] ❌ initiate-purchase failed: ${f.message}');
          return null;
        },
        (id) {
          log('[UserSub] ✅ pendingId: $id');
          return id;
        },
      );
      if (initiateCheck == null) {
        emit(
          state.copyWith(
            status: UserSubStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }
      pendingId = initiateCheck;

      log('[UserSub] 📲 applicationUserName → Apple: $pendingId');
      log('[UserSub] ════════════════════════════════════════');

      // ── Step 3: Apple IAP ─────────────────────────────────────────────────
      final purchase = await _iapService.buyProduct(
        productId,
        uniqueNumber: pendingId,
      );
      if (isClosed) return;

      log('[UserSub] ✅ Apple purchase success:');
      log('[UserSub]   purchaseID (transactionId): ${purchase.purchaseID}');
      log('[UserSub]   productID                 : ${purchase.productID}');
      log(
        '[UserSub]   transactionDate           : ${purchase.transactionDate}',
      );
      log('[UserSub]   status                    : ${purchase.status}');

      // ── Step 3: Restore على الباك-إند عشان نتحقق من الـ ownership ──────────
      // Apple بتكلم الباك مباشرة عن طريق server-to-server notifications
      // لكن لو الاشتراك كان على account تاني (CONFLICT)، لازم نعمل transfer
      final restoreResult = await _tryRestoreAfterPurchase(purchase);
      if (isClosed) return;

      if (restoreResult == _RestoreOutcome.conflict) {
        // الـ UI هيعرض dialog للـ transfer — مش نعتبره success لسه
        return;
      }

      // NEW_LINK أو مفيش restore (Apple server-to-server هيتكلم) → success
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

  // ── Restore after purchase ──────────────────────────────────────────────────

  /// بعد نجاح Apple IAP، نعمل restore على الباك-إند عشان نتحقق من الـ ownership.
  /// لو الاشتراك كان على account تاني (CONFLICT) → نعمل emit بـ needsTransfer.
  /// لو NEW_LINK أو مفيش مشكلة → نرجع success.
  Future<_RestoreOutcome> _tryRestoreAfterPurchase(
    PurchaseDetails purchase,
  ) async {
    try {
      log('[UserSub] 🔄 Running post-purchase restore check...');

      String? receipt;

      if (Platform.isIOS) {
        if (purchase is SK2PurchaseDetails) {
          // ── SK2: جرب الـ serverVerificationData أولاً ──────────────────
          final jws = purchase.verificationData.serverVerificationData;
          if (jws.isNotEmpty) {
            receipt = jws;
            log('[UserSub] ✅ Got JWS from SK2 purchase directly');
          } else {
            // ── Fallback: جيب من native getCurrentEntitlementsJWS ─────────
            // أسرع وأموثوق من restoreAndCollect في هذا السياق
            log(
              '[UserSub] 🔍 SK2 JWS empty — fetching from native entitlements',
            );
            receipt = await _getJWSFromNativeEntitlements();
          }
        } else if (purchase is AppStorePurchaseDetails) {
          receipt =
              purchase.skPaymentTransaction.payment.applicationUsername ??
              purchase.verificationData.serverVerificationData;
        }
      }

      if (receipt == null || receipt.isEmpty) {
        log('[UserSub] ⚠️ No receipt for restore check — skipping');
        return _RestoreOutcome.noReceipt;
      }

      log(
        '[UserSub] 📤 Sending receipt to backend (length: ${receipt.length})',
      );
      final result = await _membershipRepository.restorePurchase(receipt);
      if (isClosed) return _RestoreOutcome.noReceipt;

      return result.fold(
        (failure) {
          log(
            '[UserSub] ⚠️ Restore check failed: ${failure.message} — treating as success',
          );
          return _RestoreOutcome.success;
        },
        (restoreResult) {
          switch (restoreResult.restoreCase) {
            case RestoreCase.conflict:
              log('[UserSub] ⚠️ CONFLICT — subscription on another account');
              emit(
                state.copyWith(
                  status: UserSubStatus.needsTransfer,
                  transferPurchaseId: restoreResult.purchaseId,
                ),
              );
              return _RestoreOutcome.conflict;
            case RestoreCase.newLink:
              log('[UserSub] ✅ NEW_LINK — subscription linked to this account');
              return _RestoreOutcome.success;
            case RestoreCase.noSubscription:
              log(
                '[UserSub] ℹ️ NO_SUBSCRIPTION — Apple server-to-server will handle',
              );
              return _RestoreOutcome.success;
          }
        },
      );
    } catch (e) {
      log('[UserSub] ⚠️ Restore check exception: $e — treating as success');
      return _RestoreOutcome.noReceipt;
    }
  }

  /// يجيب الـ JWS من native getCurrentEntitlementsJWS channel.
  /// أسرع من restoreAndCollect لأنه بيجيب الـ current entitlements مباشرة.
  Future<String?> _getJWSFromNativeEntitlements() async {
    try {
      const channel = MethodChannel('com.athr.tayser/iap_jws');
      final List<dynamic> rawList = await channel.invokeMethod(
        'getCurrentEntitlementsJWS',
      );
      log('[UserSub] Native entitlements count: ${rawList.length}');
      for (final item in rawList) {
        if (item is Map) {
          final jws = item['jws']?.toString() ?? '';
          if (jws.isNotEmpty) {
            log('[UserSub] ✅ Got JWS from native entitlements');
            return jws;
          }
        }
      }
      log('[UserSub] ⚠️ No JWS found in native entitlements');
      return null;
    } catch (e) {
      log('[UserSub] ❌ Native entitlements error: $e');
      return null;
    }
  }

  /// يعمل transfer للاشتراك من account تاني للـ account الحالي.
  Future<void> transferSubscription(String purchaseId) async {
    if (isClosed) return;
    emit(state.copyWith(status: UserSubStatus.purchasing));

    final result = await _membershipRepository.transferSubscription(purchaseId);
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(status: UserSubStatus.error, error: failure.message),
        );
      },
      (_) {
        SubscriptionEventBus.instance.fire(
          const SubscriptionChangedEvent(subscriptionType: 'gold'),
        );
        emit(state.copyWith(status: UserSubStatus.success));
      },
    );
  }

  void resetStatus() => emit(state.copyWith(status: UserSubStatus.initial));

  // ── Android / Paymob Google Subscription ───────────────────────────────────

  /// يغير قيمة save card toggle على Android
  void setSaveCard(bool value) => emit(state.copyWith(saveCard: value));

  /// Android flow: يبدأ دفع الباقة عبر Paymob WebView
  Future<void> purchaseSubscriptionAndroid(
    List<NewUserSubModel> allSubs, {
    required BuildContext context,
  }) async {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;

    // تحديد الـ target subscription
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final NewUserSubModel targetSub;

    if (current != null) {
      final upgrade = getUpgradeSub(allSubs);
      final downgrade = getDowngradeSub(allSubs);
      if (upgrade != null) {
        targetSub = upgrade;
      } else if (downgrade != null) {
        targetSub = downgrade;
      } else {
        emit(
          state.copyWith(
            status: UserSubStatus.error,
            error: 'already_on_highest_plan',
          ),
        );
        return;
      }
    } else {
      if (state.selectedDurationIndex >= subs.length) return;
      targetSub = subs[state.selectedDurationIndex];
    }

    log('[UserSub-Android] ════════════════════════════════════════');
    log('[UserSub-Android] 🌐 ANDROID WEBVIEW FLOW');
    log('[UserSub-Android]   subscriptionId   : ${targetSub.id}');
    log('[UserSub-Android]   subscriptionType : ${targetSub.subscriptionType}');
    log('[UserSub-Android] ════════════════════════════════════════');

    emit(state.copyWith(status: UserSubStatus.purchasing));

    try {
      // Step 1: Initiate payment on backend
      final result = await _membershipRepository
          .initiateGoogleSubscriptionPayment(
            subscriptionId: targetSub.id,
            subscriptionType: 'UserSubscription',
            saveCard: false,
          );

      if (isClosed) return;

      await result.fold(
        (failure) async {
          log('[UserSub-Android] ❌ initiate failed: ${failure.message}');
          if (failure.message == 'profileIncomplete') {
            emit(state.copyWith(status: UserSubStatus.profileIncomplete));
          } else {
            emit(
              state.copyWith(
                status: UserSubStatus.error,
                error: failure.message,
              ),
            );
          }
        },
        (paymentData) async {
          if (paymentData.webviewUrl.isEmpty) {
            log('[UserSub-Android] ❌ webviewUrl is empty');
            emit(
              state.copyWith(
                status: UserSubStatus.error,
                error: 'payment_sdk_error',
              ),
            );
            return;
          }

          // Step 2: Open Paymob WebView
          if (!context.mounted) return;
          final webResult = await Navigator.of(context)
              .push<PaymobWebViewResult>(
                MaterialPageRoute(
                  builder: (_) =>
                      PaymobWebViewScreen(webviewUrl: paymentData.webviewUrl),
                ),
              );

          log('[UserSub-Android] WebView result: $webResult');

          if (isClosed) return;

          if (webResult == PaymobWebViewResult.success) {
            SubscriptionEventBus.instance.fire(
              SubscriptionChangedEvent(
                subscriptionType: targetSub.subscriptionType,
              ),
            );
            emit(state.copyWith(status: UserSubStatus.success));
          } else if (webResult == PaymobWebViewResult.pending) {
            emit(
              state.copyWith(
                status: UserSubStatus.error,
                error: 'payment_pending',
              ),
            );
          } else if (webResult == PaymobWebViewResult.closed ||
              webResult == null) {
            // المستخدم أغلق الـ WebView — نتحقق من الباك-إند عن الحالة الفعلية
            log(
              '[UserSub-Android] 🔍 Checking purchase status for orderId: ${paymentData.orderId}',
            );
            emit(state.copyWith(status: UserSubStatus.purchasing));
            final statusResult = await _membershipRepository
                .checkPaymobPurchaseStatus(paymentData.orderId);
            if (isClosed) return;

            statusResult.fold(
              (failure) {
                log(
                  '[UserSub-Android] ⚠️ Status check failed: ${failure.message} — treating as canceled',
                );
                emit(state.copyWith(status: UserSubStatus.canceled));
              },
              (status) {
                log('[UserSub-Android] 📊 Purchase status: $status');
                switch (status) {
                  case 'completed':
                    SubscriptionEventBus.instance.fire(
                      SubscriptionChangedEvent(
                        subscriptionType: targetSub.subscriptionType,
                      ),
                    );
                    emit(state.copyWith(status: UserSubStatus.success));
                  case 'pending':
                  case 'processing':
                    emit(
                      state.copyWith(
                        status: UserSubStatus.error,
                        error: 'payment_pending',
                      ),
                    );
                  case 'failed':
                  case 'canceled':
                  case 'refunded':
                  default:
                    emit(state.copyWith(status: UserSubStatus.canceled));
                }
              },
            );
          } else {
            // Rejected — المستخدم ألغى الدفع
            emit(state.copyWith(status: UserSubStatus.canceled));
          }
        },
      );
    } catch (e) {
      log('[UserSub-Android] ❌ Exception: $e');
      if (isClosed) return;
      emit(
        state.copyWith(status: UserSubStatus.error, error: 'unexpected_error'),
      );
    }
  }
}

enum _RestoreOutcome { success, conflict, noReceipt }
