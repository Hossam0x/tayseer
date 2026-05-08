import 'dart:async';
import 'dart:developer';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/features/advisor/membership/data/models/restore_purchase_result.dart';
import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_state.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/my_import.dart';
import 'package:url_launcher/url_launcher.dart';

class MembershipCubit extends Cubit<MembershipState> {
  final MembershipRepository _repository;
  late final StreamSubscription<SubscriptionChangedEvent> _subSubscription;

  MembershipCubit(this._repository) : super(MembershipInitial()) {
    loadMembership();
    _subSubscription = SubscriptionEventBus.instance.onSubscriptionChanged
        .listen((_) {
          if (isClosed) return;
          loadMembership();
        });
  }

  @override
  Future<void> close() {
    _subSubscription.cancel();
    return super.close();
  }

  Future<void> loadMembership() async {
    emit(MembershipLoading());
    final result = await _repository.getMySubscription();
    result.fold((failure) => emit(MembershipError(message: failure.message)), (
      sub,
    ) {
      if (sub.isFree) {
        emit(MembershipNoSubscription());
      } else {
        emit(MembershipLoaded(sub: sub));
      }
    });
  }

  // ── Cancel ──────────────────────────────────────────────────────────────────

  /// Opens Apple/Google subscription management, then calls the backend to
  /// record the cancellation. The backend should also receive Apple Server
  /// Notifications for the actual cancellation event.
  Future<void> cancelMembership() async {
    final current = state;
    if (current is! MembershipLoaded) return;

    emit(current.copyWith(isCancelLoading: true));

    try {
      log('[Cancel] 🚀 Opening Apple subscription management page');
      log('[Cancel] ⚠️  This only cancels auto-renew.');
      log('[Cancel]    Subscription stays active until billing period ends.');
      log(
        '[Cancel]    Apple sends DID_CHANGE_RENEWAL_STATUS webhook to backend.',
      );

      await _openSubscriptionManagement();

      log('[Cancel] ✅ User returned from subscription management page');
      log('[Cancel] 🔄 Reloading membership to reflect any changes...');

      // Apple بتبعت الـ webhook للباك تلقائياً — مش محتاجين نبعت cancel API
      // بس نعمل reload عشان نعرض الحالة الجديدة (isCancelled = true)
      emit(
        current.copyWith(
          isCancelLoading: false,
          actionSuccess: 'cancel_auto_renew_success',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await loadMembership();
    } catch (e) {
      log('[Cancel] ❌ Exception: $e');
      emit(
        current.copyWith(
          isCancelLoading: false,
          actionError: 'membership_cancel_error',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Future<void> _openSubscriptionManagement() async {
    final Uri uri;
    if (Platform.isIOS) {
      // itms-apps:// بيفتح مباشرة في الـ App Store app → Subscriptions
      // fallback: https لو itms-apps مش شغال
      final itmUri = Uri.parse(
        'itms-apps://apps.apple.com/account/subscriptions',
      );
      if (await canLaunchUrl(itmUri)) {
        await launchUrl(itmUri, mode: LaunchMode.externalApplication);
        return;
      }
      uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      uri = Uri.parse('https://play.google.com/store/account/subscriptions');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void clearMessages() {
    if (state is MembershipLoaded) {
      emit((state as MembershipLoaded).copyWith(clearMessages: true));
    }
  }

  // ── Restore Purchase ────────────────────────────────────────────────────────

  /// Restores purchases via Apple, then sends the JWS receipt to the backend.
  ///
  /// مع StoreKit 2: الـ serverVerificationData في كل transaction هو JWS (JWT)
  /// موقع من Apple — بنبعته مباشرة للباك-إند بدون أي معالجة.
  ///
  /// مع StoreKit 1 (fallback): نحاول نجيب applicationUserName أولاً،
  /// ثم serverVerificationData كـ PKCS#7 receipt.
  Future<void> restorePurchase() async {
    if (isClosed) return;
    emit(MembershipNoSubscriptionRestoring());

    try {
      final iapService = getIt<IAPService>();
      final restoredPurchases = await iapService.restoreAndCollect();

      log('[Restore] total restored: ${restoredPurchases.length}');

      if (restoredPurchases.isEmpty) {
        _emitRestoreError('restore_no_receipt');
        return;
      }

      String? receipt;
      String? originalTransactionId;

      if (Platform.isIOS) {
        // ── StoreKit 2: SK2PurchaseDetails ────────────────────────────────
        // الـ serverVerificationData هو JWS (JWT) مباشرة
        final sk2Purchase = restoredPurchases.reversed
            .whereType<SK2PurchaseDetails>()
            .firstOrNull;

        if (sk2Purchase != null) {
          final jws = sk2Purchase.verificationData.serverVerificationData;
          if (jws.isNotEmpty) {
            receipt = jws;
            log('[Restore] ✅ StoreKit 2 — using JWS (JWT)');
            log('[Restore] JWS length: ${jws.length}');
            log(
              '[Restore] JWS preview: ${jws.length > 60 ? '${jws.substring(0, 60)}...' : jws}',
            );
          }
        }

        // ── StoreKit 1 fallback: AppStorePurchaseDetails ──────────────────
        if (receipt == null || receipt.isEmpty) {
          // Pass 1: applicationUserName (JWT pendingId)
          for (final p in restoredPurchases.reversed) {
            if (p is AppStorePurchaseDetails) {
              final appUsername =
                  p.skPaymentTransaction.payment.applicationUsername;
              if (appUsername != null && appUsername.isNotEmpty) {
                receipt = appUsername;
                log(
                  '[Restore] SK1 — using applicationUserName (JWT pendingId)',
                );
                final origId = p
                    .skPaymentTransaction
                    .originalTransaction
                    ?.transactionIdentifier;
                if (origId != null && origId.isNotEmpty) {
                  originalTransactionId = origId;
                  log('[Restore] originalTransactionId: $origId');
                }
                break;
              }
            }
          }

          // Pass 2: serverVerificationData (PKCS#7)
          if (receipt == null || receipt.isEmpty) {
            log(
              '[Restore] SK1 — no JWT, using serverVerificationData (PKCS#7)',
            );
            final serverData =
                restoredPurchases.last.verificationData.serverVerificationData;
            if (serverData.isNotEmpty) {
              receipt = serverData;
              log('[Restore] serverVerificationData length: ${receipt.length}');
            }

            for (final p in restoredPurchases.reversed) {
              if (p is AppStorePurchaseDetails) {
                final origId = p
                    .skPaymentTransaction
                    .originalTransaction
                    ?.transactionIdentifier;
                if (origId != null && origId.isNotEmpty) {
                  originalTransactionId = origId;
                  log('[Restore] originalTransactionId (legacy): $origId');
                  break;
                }
              }
            }
          }
        }
      }

      if (receipt == null || receipt.isEmpty) {
        _emitRestoreError('restore_no_receipt');
        return;
      }

      final result = await _repository.restorePurchase(
        receipt,
        originalTransactionId: originalTransactionId,
      );
      result.fold(
        (failure) => _emitRestoreError(failure.message),
        (restoreResult) => _handleRestoreResult(restoreResult),
      );
    } catch (e) {
      log('[Restore] Error: $e');
      _emitRestoreError('restore_failed');
    }
  }

  void _handleRestoreResult(RestorePurchaseResult result) {
    if (isClosed) return;
    switch (result.restoreCase) {
      case RestoreCase.noSubscription:
        emit(MembershipNoSubscriptionWithMessage(message: result.message));
      case RestoreCase.newLink:
        SubscriptionEventBus.instance.fire(
          const SubscriptionChangedEvent(subscriptionType: 'gold'),
        );
        emit(
          MembershipNoSubscriptionWithMessage(
            message: result.message,
            isSuccess: true,
          ),
        );
        loadMembership();
      case RestoreCase.conflict:
        emit(
          MembershipRestoreConflict(
            message: result.message,
            purchaseId: result.purchaseId ?? '',
          ),
        );
    }
  }

  void _emitRestoreError(String messageKey) {
    if (isClosed) return;
    emit(MembershipNoSubscriptionWithMessage(message: messageKey));
  }

  /// Called when user confirms transfer in the conflict dialog.
  Future<void> transferSubscription(String purchaseId) async {
    if (isClosed) return;
    emit(MembershipNoSubscriptionRestoring());

    final result = await _repository.transferSubscription(purchaseId);
    result.fold((failure) => _emitRestoreError(failure.message), (_) {
      SubscriptionEventBus.instance.fire(
        const SubscriptionChangedEvent(subscriptionType: 'gold'),
      );
      emit(
        MembershipNoSubscriptionWithMessage(
          message: 'transfer_subscription_success',
          isSuccess: true,
        ),
      );
      loadMembership();
    });
  }
}
