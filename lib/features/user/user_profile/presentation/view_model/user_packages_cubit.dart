import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/user_packages_repository.dart';

const _kUserSubTypeKey = 'user_current_sub_type'; // 'gold' | 'ultra' | ''

class UserPackagesState {
  final List<NewUserSubModel> subscriptions;
  final bool isLoading;
  final String? errorMessage;

  UserPackagesState({
    this.subscriptions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  UserPackagesState copyWith({
    List<NewUserSubModel>? subscriptions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserPackagesState(
      subscriptions: subscriptions ?? this.subscriptions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class UserPackagesCubit extends Cubit<UserPackagesState> {
  final UserPackagesRepository _repository;
  StreamSubscription? _subscriptionSubscription;

  UserPackagesCubit(this._repository) : super(UserPackagesState()) {
    // ✅ استمع للتغييرات في الاشتراك لتحديث الـ cache
    _subscriptionSubscription = SubscriptionEventBus
        .instance
        .onSubscriptionChanged
        .listen((event) {
          if (isClosed) return;
          // ✅ حدّث الـ cache فوراً
          updateCachedSubType(event.subscriptionType);
          // ✅ حدّث البيانات من الـ API
          getPackages();
        });
  }

  @override
  Future<void> close() {
    _subscriptionSubscription?.cancel();
    return super.close();
  }

  Future<void> getPackages() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.getPackages();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (subs) {
        // Cache the current subscription type
        _cacheCurrentSubType(subs);
        emit(state.copyWith(isLoading: false, subscriptions: subs));
      },
    );
  }

  PackageType? get currentSubscribedPackage {
    if (state.subscriptions.isEmpty) return null;
    final current = state.subscriptions
        .where((s) => s.isCurrentSub)
        .firstOrNull;
    if (current == null) return null;
    if (current.subscriptionType == 'gold') return PackageType.pro;
    if (current.subscriptionType == 'ultra') return PackageType.elite;
    return null;
  }

  /// Returns cached sub type synchronously before API loads
  static Future<PackageType?> getCachedSubType() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_kUserSubTypeKey) ?? '';
    if (cached == 'gold') return PackageType.pro;
    if (cached == 'ultra') return PackageType.elite;
    return null;
  }

  static Future<void> _cacheCurrentSubType(List<NewUserSubModel> subs) async {
    final current = subs.where((s) => s.isCurrentSub).firstOrNull;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserSubTypeKey, current?.subscriptionType ?? '');
  }

  /// Call this after a successful subscription change
  static Future<void> updateCachedSubType(String subType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserSubTypeKey, subType);
  }
}
