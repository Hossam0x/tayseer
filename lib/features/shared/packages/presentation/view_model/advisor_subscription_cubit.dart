import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'packages_cubit.dart';

enum AdvisorSubStatus { initial, purchasing, success, canceled, error }

class AdvisorSubscriptionState extends Equatable {
  final int selectedDurationIndex;
  final SelectedPackage packageType;
  final AdvisorSubStatus status;
  final String? error;

  const AdvisorSubscriptionState({
    this.selectedDurationIndex = 0,
    required this.packageType,
    this.status = AdvisorSubStatus.initial,
    this.error,
  });

  AdvisorSubscriptionState copyWith({
    int? selectedDurationIndex,
    SelectedPackage? packageType,
    AdvisorSubStatus? status,
    String? error,
  }) {
    return AdvisorSubscriptionState(
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

class AdvisorSubscriptionCubit extends Cubit<AdvisorSubscriptionState> {
  final IAPService _iapService;
  final ApiService _apiService;

  AdvisorSubscriptionCubit(
    SelectedPackage packageType,
    this._iapService,
    this._apiService,
  ) : super(AdvisorSubscriptionState(packageType: packageType));

  /// يرجع الـ subscriptions المناسبة للباقة (weekly أولاً ثم monthly)
  List<NewAdvisorSubModel> getSubscriptionsForPackage(
    List<NewAdvisorSubModel> allSubs,
  ) {
    final targetType = state.packageType == SelectedPackage.elite
        ? 'ultra'
        : 'gold';
    final filtered = allSubs
        .where((s) => s.subscriptionType == targetType)
        .toList();
    filtered.sort((a, b) {
      if (a.isWeekly && b.isMonthly) return -1;
      if (a.isMonthly && b.isWeekly) return 1;
      return 0;
    });
    return filtered;
  }

  /// يرجع الـ current sub لو موجودة
  NewAdvisorSubModel? getCurrentSub(List<NewAdvisorSubModel> allSubs) {
    return getSubscriptionsForPackage(
      allSubs,
    ).where((s) => s.isCurrentSub).firstOrNull;
  }

  /// يرجع الـ upgrade option (التانية اللي مش current وليست downgrade)
  NewAdvisorSubModel? getUpgradeSub(List<NewAdvisorSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    if (current == null) return null;
    // upgrade = monthly لو current weekly
    return subs
        .where((s) => !s.isCurrentSub && !(current.isMonthly && s.isWeekly))
        .firstOrNull;
  }

  /// أول ما تيجي البيانات — لو مفيش current sub اختار الأولى
  void initSelection(List<NewAdvisorSubModel> allSubs) {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;
    final currentIndex = subs.indexWhere((s) => s.isCurrentSub);
    if (currentIndex == -1) {
      emit(state.copyWith(selectedDurationIndex: 0));
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

  void resetStatus() => emit(state.copyWith(status: AdvisorSubStatus.initial));

  Future<void> purchaseSubscription(List<NewAdvisorSubModel> allSubs) async {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;

    // لو في current sub → اشتري الـ upgrade مباشرة
    // لو مفيش → اشتري الـ selected
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final NewAdvisorSubModel targetSub;
    if (current != null) {
      final upgrade = getUpgradeSub(allSubs);
      if (upgrade == null) return;
      targetSub = upgrade;
    } else {
      if (state.selectedDurationIndex >= subs.length) return;
      targetSub = subs[state.selectedDurationIndex];
    }

    final productId = targetSub.appleProductId;
    if (productId.isEmpty) {
      emit(
        state.copyWith(
          status: AdvisorSubStatus.error,
          error: 'معرف المنتج غير متوفر',
        ),
      );
      return;
    }

    emit(state.copyWith(status: AdvisorSubStatus.purchasing));
    unawaited(_iapService.init());

    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      final response = await _apiService.post(
        endPoint: ApiEndPoint.initiateSubscriptionPurchase,
        data: {
          'productId': productId,
          'platform': platform,
          'subscriptionId': targetSub.id,
        },
      );

      if (response['success'] != true) {
        emit(
          state.copyWith(
            status: AdvisorSubStatus.error,
            error: response['message']?.toString() ?? 'فشل بدء عملية الاشتراك',
          ),
        );
        return;
      }

      final pendingId = response['data']?['pendingId'] as String? ?? '';
      await _iapService.buyProduct(productId, uniqueNumber: pendingId);
      // Notify all listeners that subscription changed
      final newType = targetSub.subscriptionType; // 'gold' or 'ultra'
      SubscriptionEventBus.instance.fire(
        SubscriptionChangedEvent(subscriptionType: newType),
      );
      emit(state.copyWith(status: AdvisorSubStatus.success));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(
        state.copyWith(
          status: err.isCanceled
              ? AdvisorSubStatus.canceled
              : AdvisorSubStatus.error,
          error: err.isCanceled ? null : err.message,
        ),
      );
    }
  }
}
