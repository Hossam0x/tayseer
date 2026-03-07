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
  static const _offlineDebounceDuration = Duration(seconds: 4);

  ConnectivityService({
    Connectivity? connectivity,
    InternetConnection? internetChecker,
  }) : _connectivity = connectivity ?? Connectivity(),
       _internetChecker =
           internetChecker ??
           InternetConnection.createInstance(
             customCheckOptions: [
               InternetCheckOption(
                 uri: Uri.parse('https://one.one.one.one'),
                 timeout: const Duration(seconds: 10),
               ),
               InternetCheckOption(
                 uri: Uri.parse('https://icanhazip.com/'),
                 timeout: const Duration(seconds: 10),
               ),
               InternetCheckOption(
                 uri: Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
                 timeout: const Duration(seconds: 10),
               ),
             ],
             useDefaultOptions: false,
           );

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
  /// يعيد المحاولة مرة واحدة قبل إعلان الأوفلاين (لتجنب false positive على النت البطيء)
  Future<bool> _checkRealConnectivity() async {
    try {
      final result = await _internetChecker.hasInternetAccess;
      if (result) return true;
      // إعادة محاولة بعد 2 ثانية قبل إعلان الأوفلاين
      await Future.delayed(const Duration(seconds: 2));
      return await _internetChecker.hasInternetAccess;
    } catch (e) {
      debugPrint('ConnectivityService: Error checking connectivity: $e');
      return false;
    }
  }

  /// Debounce لمنع التذبذب السريع
  void _emitDebounced(bool newValue) {
    _debounceTimer?.cancel();

    // لو الاتصال رجع → يبثّ فوراً (بدون debounce) عشان الـ UX
    if (newValue && !_isConnected) {
      _isConnected = true;
      if (!_isDisposed) _controller.add(true);
      return;
    }

    // لو الاتصال انقطع → debounce عشان نتأكد (يتجنب false positive على النت البطيء)
    _debounceTimer = Timer(_offlineDebounceDuration, () {
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
