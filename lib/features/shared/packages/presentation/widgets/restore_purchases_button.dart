import 'dart:developer';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/membership/data/models/restore_purchase_result.dart';
import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_restore_conflict_dialog.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_success_dialog.dart';
import 'package:tayseer/my_import.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

/// زرار Restore Purchases مستقل — يشتغل من أي شاشة بدون الحاجة لـ MembershipCubit
/// بيستخدم IAPService و MembershipRepository مباشرة من getIt
class RestorePurchasesButton extends StatefulWidget {
  /// لون النص — أبيض على خلفية داكنة، أو اللون الأساسي على خلفية فاتحة
  final Color? textColor;

  const RestorePurchasesButton({super.key, this.textColor});

  @override
  State<RestorePurchasesButton> createState() => _RestorePurchasesButtonState();
}

class _RestorePurchasesButtonState extends State<RestorePurchasesButton> {
  bool _isRestoring = false;

  Future<void> _restore() async {
    if (_isRestoring) return;
    setState(() => _isRestoring = true);

    try {
      final iapService = getIt<IAPService>();
      final repository = getIt<MembershipRepository>();

      final restoredPurchases = await iapService.restoreAndCollect();
      log('[Restore] total restored: ${restoredPurchases.length}');

      if (restoredPurchases.isEmpty) {
        if (mounted) AppToast.error(context, 'restore_no_receipt');
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
          }
        }

        // ── StoreKit 1 fallback ───────────────────────────────────────────
        if (receipt == null || receipt.isEmpty) {
          // Pass 1: applicationUserName (JWT pendingId)
          for (final p in restoredPurchases.reversed) {
            if (p is AppStorePurchaseDetails) {
              final appUsername =
                  p.skPaymentTransaction.payment.applicationUsername;
              if (appUsername != null && appUsername.isNotEmpty) {
                receipt = appUsername;
                final origId = p
                    .skPaymentTransaction
                    .originalTransaction
                    ?.transactionIdentifier;
                if (origId != null && origId.isNotEmpty) {
                  originalTransactionId = origId;
                }
                break;
              }
            }
          }
          // Pass 2: serverVerificationData (PKCS#7)
          if (receipt == null || receipt.isEmpty) {
            final serverData =
                restoredPurchases.last.verificationData.serverVerificationData;
            if (serverData.isNotEmpty) receipt = serverData;

            for (final p in restoredPurchases.reversed) {
              if (p is AppStorePurchaseDetails) {
                final origId = p
                    .skPaymentTransaction
                    .originalTransaction
                    ?.transactionIdentifier;
                if (origId != null && origId.isNotEmpty) {
                  originalTransactionId = origId;
                  break;
                }
              }
            }
          }
        }
      }

      if (receipt == null || receipt.isEmpty) {
        if (mounted) AppToast.error(context, 'restore_no_receipt');
        return;
      }

      final result = await repository.restorePurchase(
        receipt,
        originalTransactionId: originalTransactionId,
      );
      result.fold((failure) {
        if (mounted) AppToast.error(context, failure.message);
      }, (restoreResult) => _handleResult(restoreResult));
    } catch (e) {
      log('[Restore] Error: $e');
      if (mounted) AppToast.error(context, 'restore_failed');
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _handleResult(RestorePurchaseResult result) {
    if (!mounted) return;
    switch (result.restoreCase) {
      case RestoreCase.noSubscription:
        AppToast.error(context, result.message);
      case RestoreCase.newLink:
        SubscriptionEventBus.instance.fire(
          const SubscriptionChangedEvent(subscriptionType: 'gold'),
        );
        showMembershipSuccessDialog(
          context,
          messageKey: 'restore_membership_success',
        );
      case RestoreCase.conflict:
        showRestoreConflictDialog(
          context,
          message: result.message,
          onTransfer: () => _transferSubscription(result.purchaseId),
        );
    }
  }

  Future<void> _transferSubscription(String? purchaseId) async {
    if (purchaseId == null || purchaseId.isEmpty) {
      if (mounted) AppToast.error(context, 'restore_failed');
      return;
    }
    setState(() => _isRestoring = true);
    try {
      final repository = getIt<MembershipRepository>();
      final result = await repository.transferSubscription(purchaseId);
      if (!mounted) return;
      result.fold((failure) => AppToast.error(context, failure.message), (_) {
        SubscriptionEventBus.instance.fire(
          const SubscriptionChangedEvent(subscriptionType: 'gold'),
        );
        showMembershipSuccessDialog(
          context,
          messageKey: 'restore_membership_success',
        );
      });
    } catch (e) {
      log('[Restore Transfer] Error: $e');
      if (mounted) AppToast.error(context, 'restore_failed');
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.textColor ?? Colors.white.withOpacity(0.85);

    if (_isRestoring) {
      return SizedBox(
        height: 36.h,
        child: Center(
          child: SizedBox(
            width: 18.w,
            height: 18.w,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          ),
        ),
      );
    }

    return TextButton(
      onPressed: _restore,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      ),
      child: Text(
        context.tr('restore_membership'),
        style: TextStyle(
          fontSize: 13.sp,
          color: color,
          decoration: TextDecoration.underline,
          decorationColor: color,
        ),
      ),
    );
  }
}
