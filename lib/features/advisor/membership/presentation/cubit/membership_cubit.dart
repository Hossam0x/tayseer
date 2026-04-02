import 'package:tayseer/features/advisor/membership/data/repositories/membership_repository.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:url_launcher/url_launcher.dart';

class MembershipCubit extends Cubit<MembershipState> {
  final MembershipRepository _repository;

  MembershipCubit(this._repository) : super(MembershipInitial()) {
    loadMembership();
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

  /// يفتح صفحة إدارة الاشتراكات في Apple أو Google
  /// وبعد ما المستخدم يرجع يكلم الباك عشان يحدث الحالة
  Future<void> cancelMembership() async {
    final current = state;
    if (current is! MembershipLoaded) return;

    emit(current.copyWith(isCancelLoading: true));

    try {
      // فتح صفحة إلغاء الاشتراك في المتجر
      await _openSubscriptionManagement();

      // بعد ما المستخدم يرجع من المتجر، نكلم الباك عشان يسجل الإلغاء
      final result = await _repository.cancelMySubscription();
      result.fold(
        (failure) => emit(
          current.copyWith(
            isCancelLoading: false,
            actionError: failure.message,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
        (_) async {
          emit(
            current.copyWith(
              isCancelLoading: false,
              actionSuccess: 'cancel_membership_success',
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ),
          );
          await loadMembership();
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

  void clearMessages() {
    if (state is MembershipLoaded) {
      emit((state as MembershipLoaded).copyWith(clearMessages: true));
    }
  }
}
