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
import 'package:tayseer/core/services/appsflyer_events/appsflyer_events.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/services/paymob_service/paymob_webview_screen.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/membership/data/models/restore_purchase_result.dart';
import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'packages_cubit.dart';

enum AdvisorSubStatus {
  initial,
  purchasing,
  success,
  canceled,
  error,
  needsTransfer, // ✅ Apple purchase نجح لكن الاشتراك على account تاني
  awaitingSaveCardChoice, // ✅ Android: ننتظر اختيار المستخدم لـ save card
  profileIncomplete, // ✅ الـ profile ناقص (phoneRequired)
}

class AdvisorSubscriptionState extends Equatable {
  final int selectedDurationIndex;
  final SelectedPackage packageType;
  final AdvisorSubStatus status;
  final String? error;
  final String?
  transferPurchaseId; // ✅ purchaseId للـ transfer في حالة CONFLICT
  final bool
  saveCard; // ✅ Android: هل يحفظ الكارت للـ auto-renew — محجوز للاستخدام المستقبلي

  const AdvisorSubscriptionState({
    this.selectedDurationIndex = 0,
    required this.packageType,
    this.status = AdvisorSubStatus.initial,
    this.error,
    this.transferPurchaseId,
    this.saveCard = false,
  });

  AdvisorSubscriptionState copyWith({
    int? selectedDurationIndex,
    SelectedPackage? packageType,
    AdvisorSubStatus? status,
    String? error,
    String? transferPurchaseId,
    bool? saveCard,
  }) {
    return AdvisorSubscriptionState(
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

class AdvisorSubscriptionCubit extends Cubit<AdvisorSubscriptionState> {
  final IAPService _iapService;
  final MembershipRepository _membershipRepository;

  AdvisorSubscriptionCubit(
    SelectedPackage packageType,
    this._iapService,
    this._membershipRepository,
  ) : super(AdvisorSubscriptionState(packageType: packageType));

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

  Future<void> purchaseSubscription(List<NewAdvisorSubModel> allSubs) async {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;

    // ── Step 1: تحديد الـ target subscription ────────────────────────────
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final NewAdvisorSubModel targetSub;

    if (current != null) {
      if (current.isActiveInApple) {
        // اشتراك نشط → upgrade فقط
        final upgrade = getUpgradeSub(allSubs);
        if (upgrade == null) {
          log(
            '[AdvisorSub] ⚠️ No upgrade available — current is active in Apple',
          );
          // أعلم الـ user إنه على أعلى خطة متاحة
          emit(
            state.copyWith(
              status: AdvisorSubStatus.error,
              error: 'already_on_highest_plan',
            ),
          );
          return;
        }
        targetSub = upgrade;
        log(
          '[AdvisorSub] 📈 UPGRADE: ${current.subscriptionDurationType} → ${targetSub.subscriptionDurationType}',
        );
      } else {
        // الاشتراك ملغي auto-renew → upgrade أو downgrade
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
          emit(
            state.copyWith(
              status: AdvisorSubStatus.error,
              error: 'already_on_highest_plan',
            ),
          );
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

    // تهيئة الـ IAP service قبل الشراء — iOS فقط
    // على Android الـ Paymob flow مش محتاج IAPService
    if (Platform.isIOS) {
      try {
        await _iapService.init();
      } catch (e) {
        log('[AdvisorSub] ❌ IAP init failed: $e');
        emit(
          state.copyWith(
            status: AdvisorSubStatus.error,
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
      log('[AdvisorSub] 📤 Will call initiate-purchase next...');
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

      // ── Step 2: Initiate purchase on backend → get pendingId ──────────────
      log('[AdvisorSub] 📤 Calling /iap/initiate-purchase...');
      final initiateResult = await _membershipRepository.initiatePurchase(
        productId: productId,
        platform: platform,
      );
      if (isClosed) return;

      final String pendingId;
      final initiateCheck = initiateResult.fold<String?>(
        (f) {
          log('[AdvisorSub] ❌ initiate-purchase failed: ${f.message}');
          return null;
        },
        (id) {
          log('[AdvisorSub] ✅ pendingId: $id');
          return id;
        },
      );
      if (initiateCheck == null) {
        emit(
          state.copyWith(
            status: AdvisorSubStatus.error,
            error: 'فشل تسجيل عملية الشراء',
          ),
        );
        return;
      }
      pendingId = initiateCheck;

      log('[AdvisorSub] 📲 applicationUserName → Apple: $pendingId');
      log('[AdvisorSub] ════════════════════════════════════════');

      // ── Step 3: Apple IAP ─────────────────────────────────────────────────
      final purchase = await _iapService.buyProduct(
        productId,
        uniqueNumber: pendingId,
      );

      log('[AdvisorSub] ✅ Apple purchase success:');
      log('[AdvisorSub]   purchaseID (transactionId): ${purchase.purchaseID}');
      log('[AdvisorSub]   productID                 : ${purchase.productID}');
      log(
        '[AdvisorSub]   transactionDate           : ${purchase.transactionDate}',
      );
      log('[AdvisorSub]   status                    : ${purchase.status}');

      // ── Step 3: Restore على الباك-إند عشان نتحقق من الـ ownership ──────────
      // Apple بتكلم الباك مباشرة عن طريق server-to-server notifications
      // لكن لو الاشتراك كان على account تاني (CONFLICT)، لازم نعمل transfer
      final restoreResult = await _tryRestoreAfterPurchase(purchase);
      if (isClosed) return;

      if (restoreResult == _AdvisorRestoreOutcome.conflict) {
        // الـ UI هيعرض dialog للـ transfer — مش نعتبره success لسه
        return;
      }

      // NEW_LINK أو مفيش restore (Apple server-to-server هيتكلم) → success
      final newType = targetSub.subscriptionType;
      SubscriptionEventBus.instance.fire(
        SubscriptionChangedEvent(subscriptionType: newType),
      );
      // 📊 AF: subscription purchased (iOS)
      unawaited(
        AppsFlyerEvents.subscriptionPurchased(
          planId: targetSub.id,
          revenue: targetSub.price?.toDouble() ?? 0,
          currency: targetSub.currency ?? 'USD',
        ),
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

  // ── Restore after purchase ──────────────────────────────────────────────────

  Future<_AdvisorRestoreOutcome> _tryRestoreAfterPurchase(
    PurchaseDetails purchase,
  ) async {
    try {
      log('[AdvisorSub] 🔄 Running post-purchase restore check...');

      String? receipt;
      if (Platform.isIOS) {
        if (purchase is SK2PurchaseDetails) {
          final jws = purchase.verificationData.serverVerificationData;
          if (jws.isNotEmpty) {
            receipt = jws;
            log('[AdvisorSub] ✅ Got JWS from SK2 purchase directly');
          } else {
            log(
              '[AdvisorSub] 🔍 SK2 JWS empty — fetching from native entitlements',
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
        log('[AdvisorSub] ⚠️ No receipt for restore check — skipping');
        return _AdvisorRestoreOutcome.noReceipt;
      }

      log(
        '[AdvisorSub] 📤 Sending receipt to backend (length: ${receipt.length})',
      );
      final result = await _membershipRepository.restorePurchase(receipt);
      if (isClosed) return _AdvisorRestoreOutcome.noReceipt;

      return result.fold(
        (failure) {
          log(
            '[AdvisorSub] ⚠️ Restore check failed: ${failure.message} — treating as success',
          );
          return _AdvisorRestoreOutcome.success;
        },
        (restoreResult) {
          switch (restoreResult.restoreCase) {
            case RestoreCase.conflict:
              log('[AdvisorSub] ⚠️ CONFLICT — subscription on another account');
              emit(
                state.copyWith(
                  status: AdvisorSubStatus.needsTransfer,
                  transferPurchaseId: restoreResult.purchaseId,
                ),
              );
              return _AdvisorRestoreOutcome.conflict;
            case RestoreCase.newLink:
              log(
                '[AdvisorSub] ✅ NEW_LINK — subscription linked to this account',
              );
              return _AdvisorRestoreOutcome.success;
            case RestoreCase.noSubscription:
              log(
                '[AdvisorSub] ℹ️ NO_SUBSCRIPTION — Apple server-to-server will handle',
              );
              return _AdvisorRestoreOutcome.success;
          }
        },
      );
    } catch (e) {
      log('[AdvisorSub] ⚠️ Restore check exception: $e — treating as success');
      return _AdvisorRestoreOutcome.noReceipt;
    }
  }

  Future<String?> _getJWSFromNativeEntitlements() async {
    try {
      const channel = MethodChannel('com.athr.tayser/iap_jws');
      final List<dynamic> rawList = await channel.invokeMethod(
        'getCurrentEntitlementsJWS',
      );
      log('[AdvisorSub] Native entitlements count: ${rawList.length}');
      for (final item in rawList) {
        if (item is Map) {
          final jws = item['jws']?.toString() ?? '';
          if (jws.isNotEmpty) {
            log('[AdvisorSub] ✅ Got JWS from native entitlements');
            return jws;
          }
        }
      }
      log('[AdvisorSub] ⚠️ No JWS found in native entitlements');
      return null;
    } catch (e) {
      log('[AdvisorSub] ❌ Native entitlements error: $e');
      return null;
    }
  }

  /// يعمل transfer للاشتراك من account تاني للـ account الحالي.
  Future<void> transferSubscription(String purchaseId) async {
    if (isClosed) return;
    emit(state.copyWith(status: AdvisorSubStatus.purchasing));

    final result = await _membershipRepository.transferSubscription(purchaseId);
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: AdvisorSubStatus.error,
            error: failure.message,
          ),
        );
      },
      (_) {
        SubscriptionEventBus.instance.fire(
          const SubscriptionChangedEvent(subscriptionType: 'gold'),
        );
        emit(state.copyWith(status: AdvisorSubStatus.success));
      },
    );
  }

  void resetStatus() => emit(state.copyWith(status: AdvisorSubStatus.initial));

  // ── Android / Paymob Google Subscription ───────────────────────────────────

  /// يغير قيمة save card toggle على Android
  void setSaveCard(bool value) => emit(state.copyWith(saveCard: value));

  /// Android flow: يبدأ دفع الباقة عبر Paymob WebView
  /// [firstName], [lastName], [phone] — بيانات المستخدم المطلوبة لـ Paymob
  Future<void> purchaseSubscriptionAndroid(
    List<NewAdvisorSubModel> allSubs, {
    required BuildContext context,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;

    // تحديد الـ target subscription
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final NewAdvisorSubModel targetSub;

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
            status: AdvisorSubStatus.error,
            error: 'already_on_highest_plan',
          ),
        );
        return;
      }
    } else {
      if (state.selectedDurationIndex >= subs.length) return;
      targetSub = subs[state.selectedDurationIndex];
    }

    log('[AdvisorSub-Android] ════════════════════════════════════════');
    log('[AdvisorSub-Android] 🌐 ANDROID WEBVIEW FLOW');
    log('[AdvisorSub-Android]   subscriptionId   : ${targetSub.id}');
    log(
      '[AdvisorSub-Android]   subscriptionType : ${targetSub.subscriptionType}',
    );
    log('[AdvisorSub-Android] ════════════════════════════════════════');

    emit(state.copyWith(status: AdvisorSubStatus.purchasing));

    try {
      // Step 1: Initiate payment on backend
      final result = await _membershipRepository
          .initiateGoogleSubscriptionPayment(
            subscriptionId: targetSub.id,
            subscriptionType: 'AdvisorSubscription',
            saveCard: false,
            firstName: firstName,
            lastName: lastName,
            phone: phone,
          );

      if (isClosed) return;

      await result.fold(
        (failure) async {
          log('[AdvisorSub-Android] ❌ initiate failed: ${failure.message}');
          if (failure.message == 'profileIncomplete') {
            emit(state.copyWith(status: AdvisorSubStatus.profileIncomplete));
          } else {
            emit(
              state.copyWith(
                status: AdvisorSubStatus.error,
                error: failure.message,
              ),
            );
          }
        },
        (paymentData) async {
          if (paymentData.webviewUrl.isEmpty) {
            log('[AdvisorSub-Android] ❌ webviewUrl is empty');
            emit(
              state.copyWith(
                status: AdvisorSubStatus.error,
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

          log('[AdvisorSub-Android] WebView result: $webResult');

          if (isClosed) return;

          if (webResult == PaymobWebViewResult.success) {
            SubscriptionEventBus.instance.fire(
              SubscriptionChangedEvent(
                subscriptionType: targetSub.subscriptionType,
              ),
            );
            // 📊 AF: subscription purchased (Android)
            unawaited(
              AppsFlyerEvents.subscriptionPurchased(
                planId: targetSub.id,
                revenue: targetSub.price?.toDouble() ?? 0,
                currency: targetSub.currency ?? 'USD',
              ),
            );
            emit(state.copyWith(status: AdvisorSubStatus.success));
          } else if (webResult == PaymobWebViewResult.pending) {
            emit(
              state.copyWith(
                status: AdvisorSubStatus.error,
                error: 'payment_pending',
              ),
            );
          } else if (webResult == PaymobWebViewResult.closed ||
              webResult == null) {
            // المستخدم أغلق الـ WebView — نتحقق من الباك-إند عن الحالة الفعلية
            log(
              '[AdvisorSub-Android] 🔍 Checking purchase status for orderId: ${paymentData.orderId}',
            );
            emit(state.copyWith(status: AdvisorSubStatus.purchasing));
            final statusResult = await _membershipRepository
                .checkPaymobPurchaseStatus(paymentData.orderId);
            if (isClosed) return;

            statusResult.fold(
              (failure) {
                log(
                  '[AdvisorSub-Android] ⚠️ Status check failed: ${failure.message} — treating as canceled',
                );
                emit(state.copyWith(status: AdvisorSubStatus.canceled));
              },
              (status) {
                log('[AdvisorSub-Android] 📊 Purchase status: $status');
                switch (status) {
                  case 'completed':
                    SubscriptionEventBus.instance.fire(
                      SubscriptionChangedEvent(
                        subscriptionType: targetSub.subscriptionType,
                      ),
                    );
                    unawaited(
                      AppsFlyerEvents.subscriptionPurchased(
                        planId: targetSub.id,
                        revenue: targetSub.price?.toDouble() ?? 0,
                        currency: targetSub.currency ?? 'USD',
                      ),
                    );
                    emit(state.copyWith(status: AdvisorSubStatus.success));
                  case 'pending':
                  case 'processing':
                    emit(
                      state.copyWith(
                        status: AdvisorSubStatus.error,
                        error: 'payment_pending',
                      ),
                    );
                  case 'failed':
                  case 'canceled':
                  case 'refunded':
                  default:
                    emit(state.copyWith(status: AdvisorSubStatus.canceled));
                }
              },
            );
          } else {
            // Rejected — المستخدم ألغى الدفع
            emit(state.copyWith(status: AdvisorSubStatus.canceled));
          }
        },
      );
    } catch (e) {
      log('[AdvisorSub-Android] ❌ Exception: $e');
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AdvisorSubStatus.error,
          error: 'unexpected_error',
        ),
      );
    }
  }
}

enum _AdvisorRestoreOutcome { success, conflict, noReceipt }
