import 'dart:async';
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
      await _openSubscriptionManagement();

      final result = await _userRepository.cancelMySubscription();
      result.fold(
        (failure) => emit(
          current.copyWith(
            isCancelLoading: false,
            actionError: failure.message,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
        (_) async {
          SubscriptionEventBus.instance.fire(
            const SubscriptionChangedEvent(subscriptionType: 'free'),
          );
          emit(
            current.copyWith(
              isCancelLoading: false,
              actionSuccess: 'cancel_membership_success',
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
          await loadUserMembership();
        },
      );
    } catch (e) {
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
      uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      uri = Uri.parse('https://play.google.com/store/account/subscriptions');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
