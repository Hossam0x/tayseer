import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/services/iap_service.dart';
import 'package:tayseer/core/utils/api_endpoint.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';

enum UserSubStatus { initial, purchasing, success, canceled, error }

class UserSubscriptionState extends Equatable {
  final int selectedDurationIndex;
  final SelectedPackage packageType;
  final UserSubStatus status;
  final String? error;

  const UserSubscriptionState({
    this.selectedDurationIndex = 0,
    required this.packageType,
    this.status = UserSubStatus.initial,
    this.error,
  });

  UserSubscriptionState copyWith({
    int? selectedDurationIndex,
    SelectedPackage? packageType,
    UserSubStatus? status,
    String? error,
  }) {
    return UserSubscriptionState(
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

class UserSubscriptionCubit extends Cubit<UserSubscriptionState> {
  final IAPService _iapService;
  final ApiService _apiService;

  UserSubscriptionCubit(
    SelectedPackage packageType,
    this._iapService,
    this._apiService,
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

  void resetStatus() => emit(state.copyWith(status: UserSubStatus.initial));

  Future<void> purchaseSubscription(List<NewUserSubModel> allSubs) async {
    final subs = getSubscriptionsForPackage(allSubs);
    if (subs.isEmpty) return;

    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final NewUserSubModel targetSub;
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
          status: UserSubStatus.error,
          error: 'معرف المنتج غير متوفر',
        ),
      );
      return;
    }

    emit(state.copyWith(status: UserSubStatus.purchasing));
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
            status: UserSubStatus.error,
            error: response['message']?.toString() ?? 'فشل بدء عملية الاشتراك',
          ),
        );
        return;
      }

      final pendingId = response['data']?['pendingId'] as String? ?? '';
      final purchase = await _iapService.buyProduct(
        productId,
        uniqueNumber: pendingId,
      );

      SubscriptionEventBus.instance.fire(
        SubscriptionChangedEvent(subscriptionType: targetSub.subscriptionType),
      );
      emit(state.copyWith(status: UserSubStatus.success));
    } catch (e) {
      final err = IAPErrorHandler.handle(e);
      emit(
        state.copyWith(
          status: err.isCanceled ? UserSubStatus.canceled : UserSubStatus.error,
          error: err.isCanceled ? null : err.message,
        ),
      );
    }
  }
}
