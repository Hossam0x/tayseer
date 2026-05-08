import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_cubit.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_state.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_membership_repository.dart';
import 'package:tayseer/my_import.dart';
import 'package:url_launcher/url_launcher.dart';

/// Extends MembershipCubit so MembershipManagementView can reuse it as-is
/// (all context.read<MembershipCubit>() calls work transparently).
class UserMembershipCubit extends MembershipCubit {
  final UserMembershipRepository _userRepository;
  late final StreamSubscription<SubscriptionChangedEvent> _userSubSubscription;

  /// [realRepository] is the advisor MembershipRepository — used for
  /// restorePurchase and transferSubscription (same endpoints for both user/advisor).
  UserMembershipCubit(this._userRepository, MembershipRepository realRepository)
    : super(realRepository) {
    loadUserMembership();
    _userSubSubscription = SubscriptionEventBus.instance.onSubscriptionChanged
        .listen((_) {
          if (isClosed) return;
          loadUserMembership();
        });
  }

  @override
  Future<void> close() {
    _userSubSubscription.cancel();
    return super.close();
  }

  Future<void> loadUserMembership() async {
    emit(MembershipLoading());
    final result = await _userRepository.getMySubscription();
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

  @override
  Future<void> loadMembership() => loadUserMembership();

  @override
  Future<void> cancelMembership() async {
    final current = state;
    if (current is! MembershipLoaded) return;

    emit(current.copyWith(isCancelLoading: true));

    try {
      log('[UserCancel] 🚀 Opening Apple subscription management page');
      log('[UserCancel] ⚠️  This only cancels auto-renew.');
      log(
        '[UserCancel]    Subscription stays active until billing period ends.',
      );
      log(
        '[UserCancel]    Apple sends DID_CHANGE_RENEWAL_STATUS webhook to backend.',
      );

      await _openSubscriptionManagement();

      log('[UserCancel] ✅ User returned from subscription management page');
      log('[UserCancel] 🔄 Reloading membership to reflect any changes...');

      // Apple بتبعت الـ webhook للباك تلقائياً — مش محتاجين نبعت cancel API
      // بس نعمل reload عشان نعرض الحالة الجديدة (isCancelled = true)
      emit(
        current.copyWith(
          isCancelLoading: false,
          actionSuccess: 'cancel_auto_renew_success',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await loadUserMembership();
    } catch (e) {
      log('[UserCancel] ❌ Exception: $e');
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
}
