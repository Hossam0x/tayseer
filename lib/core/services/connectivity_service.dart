import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// خدمة مراقبة الاتصال بالإنترنت في الوقت الفعلي
/// تجمع بين connectivity_plus (للكشف عن تغيير الشبكة) و internet_connection_checker_plus (للتحقق الفعلي)
class ConnectivityService {
  final Connectivity _connectivity;
  final InternetConnection _internetChecker;

  final _controller = StreamController<bool>.broadcast();
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _internetSubscription;

  bool _isConnected = true;
  bool _isDisposed = false;

  // Debounce timer لمنع التذبذب السريع
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(seconds: 2);

  ConnectivityService({
    Connectivity? connectivity,
    InternetConnection? internetChecker,
  }) : _connectivity = connectivity ?? Connectivity(),
       _internetChecker = internetChecker ?? InternetConnection();

  /// البدء في مراقبة الاتصال
  Future<void> initialize() async {
    // فحص أولي
    _isConnected = await _checkRealConnectivity();
    _controller.add(_isConnected);

    // الاستماع لتغييرات connectivity_plus
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) async {
      final hasInterface = results.any((r) => r != ConnectivityResult.none);

      if (!hasInterface) {
        // لا يوجد اتصال شبكة مباشرة → أوفلاين فوراً
        _emitDebounced(false);
      } else {
        // يوجد شبكة → تحقق من الوصول الفعلي للإنترنت
        final hasInternet = await _checkRealConnectivity();
        _emitDebounced(hasInternet);
      }
    });

    // الاستماع لتغييرات internet_connection_checker_plus كطبقة إضافية
    _internetSubscription = _internetChecker.onStatusChange.listen((status) {
      final isConnected = status == InternetStatus.connected;
      _emitDebounced(isConnected);
    });
  }

  /// فحص الاتصال الفعلي بالإنترنت (ليس فقط الشبكة)
  Future<bool> _checkRealConnectivity() async {
    try {
      return await _internetChecker.hasInternetAccess;
    } catch (e) {
      debugPrint('ConnectivityService: Error checking connectivity: $e');
      return false;
    }
  }

  /// Debounce لمنع التذبذب السريع
  void _emitDebounced(bool newValue) {
    _debounceTimer?.cancel();

    // لو الاتصال انقطع → يبثّ فوراً (بدون debounce)
    if (!newValue && _isConnected) {
      _isConnected = false;
      if (!_isDisposed) _controller.add(false);
      return;
    }

    // لو الاتصال رجع → debounce عشان نتأكد
    _debounceTimer = Timer(_debounceDuration, () {
      if (newValue != _isConnected && !_isDisposed) {
        _isConnected = newValue;
        _controller.add(_isConnected);
      }
    });
  }

  /// هل متصل حالياً؟
  bool get isConnected => _isConnected;

  /// فحص لحظي (يسأل الشبكة فعلياً)
  Future<bool> checkNow() async {
    _isConnected = await _checkRealConnectivity();
    return _isConnected;
  }

  /// Stream بتغييرات الاتصال
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// تنظيف الموارد
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _connectivitySubscription?.cancel();
    _internetSubscription?.cancel();
    _controller.close();
  }
}
