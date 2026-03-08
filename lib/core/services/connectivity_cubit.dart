import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/services/connectivity_service.dart';

/// حالة الاتصال
class ConnectivityState extends Equatable {
  final bool isConnected;

  const ConnectivityState({required this.isConnected});

  const ConnectivityState.initial() : isConnected = true;

  ConnectivityState copyWith({bool? isConnected}) {
    return ConnectivityState(isConnected: isConnected ?? this.isConnected);
  }

  @override
  List<Object?> get props => [isConnected];
}

/// Cubit عالمي لحالة الاتصال — يُستخدم في كل أجزاء التطبيق
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;

  ConnectivityCubit(this._connectivityService)
    : super(ConnectivityState(isConnected: _connectivityService.isConnected)) {
    _subscription = _connectivityService.onConnectivityChanged.listen((
      isConnected,
    ) {
      emit(state.copyWith(isConnected: isConnected));
    });
  }

  /// هل متصل حالياً؟
  bool get isOnline => state.isConnected;

  /// هل غير متصل؟
  bool get isOffline => !state.isConnected;

  /// فحص لحظي (يسأل الشبكة فعلياً)
  Future<bool> checkNow() async {
    final result = await _connectivityService.checkNow();
    emit(state.copyWith(isConnected: result));
    return result;
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
