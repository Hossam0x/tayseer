import 'dart:developer';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/membership/data/models/restore_purchase_result.dart';
import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';
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
        _showError('restore_no_receipt');
        return;
      }

      String? receipt;

      if (Platform.isIOS) {
        // Pass 1: applicationUserName (JWT pendingId)
        for (final p in restoredPurchases.reversed) {
          if (p is AppStorePurchaseDetails) {
            final appUsername =
                p.skPaymentTransaction.payment.applicationUsername;
            if (appUsername != null && appUsername.isNotEmpty) {
              receipt = appUsername;
              break;
            }
          }
        }
        // Pass 2: serverVerificationData
        if (receipt == null || receipt.isEmpty) {
          final serverData =
              restoredPurchases.last.verificationData.serverVerificationData;
          if (serverData.isNotEmpty) receipt = serverData;
        }
      }

      if (receipt == null || receipt.isEmpty) {
        _showError('restore_no_receipt');
        return;
      }

      final result = await repository.restorePurchase(receipt);
      result.fold(
        (failure) => _showError(failure.message),
        (restoreResult) => _handleResult(restoreResult),
      );
    } catch (e) {
      log('[Restore] Error: $e');
      _showError('restore_failed');
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  void _handleResult(RestorePurchaseResult result) {
    if (!mounted) return;
    switch (result.restoreCase) {
      case RestoreCase.noSubscription:
        _showError(result.message);
      case RestoreCase.newLink:
        SubscriptionEventBus.instance.fire(
          const SubscriptionChangedEvent(subscriptionType: 'gold'),
        );
        _showSuccess('restore_membership_success');
      case RestoreCase.conflict:
        // في حالة الـ conflict نعرض رسالة خطأ بسيطة من هنا
        // الـ conflict dialog الكامل موجود في MembershipManagementView
        _showError(result.message);
    }
  }

  void _showError(String key) {
    if (!mounted) return;
    AppToast.error(context, key);
  }

  void _showSuccess(String key) {
    if (!mounted) return;
    AppToast.success(context, key);
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
