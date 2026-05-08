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

  /// Restores purchases via Apple, then sends the receipt to the backend.
  ///
  /// Receipt priority:
  ///   1. applicationUserName (JWT pendingId) — set when purchase was made
  ///      via this app's backend flow.
  ///   2. serverVerificationData — the App Receipt from Apple (Base64 encoded
  ///      PKCS7 blob). The backend must verify this with Apple's servers.
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

      if (Platform.isIOS) {
        // Pass 1: applicationUserName (JWT pendingId) — new purchases
        for (final p in restoredPurchases.reversed) {
          if (p is AppStorePurchaseDetails) {
            final appUsername =
                p.skPaymentTransaction.payment.applicationUsername;
            if (appUsername != null && appUsername.isNotEmpty) {
              receipt = appUsername;
              log('[Restore] using applicationUserName (JWT)');
              break;
            }
          }
        }

        // Pass 2: serverVerificationData (App Receipt) — legacy purchases
        if (receipt == null || receipt.isEmpty) {
          log('[Restore] no JWT — using serverVerificationData');
          final serverData =
              restoredPurchases.last.verificationData.serverVerificationData;
          if (serverData.isNotEmpty) {
            receipt = serverData;
            log('[Restore] serverVerificationData length: ${receipt.length}');
          }
        }
      }

      if (receipt == null || receipt.isEmpty) {
        _emitRestoreError('restore_no_receipt');
        return;
      }

      final result = await _repository.restorePurchase(receipt);
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
