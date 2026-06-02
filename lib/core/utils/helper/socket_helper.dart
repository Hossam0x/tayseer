import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/core/services/secure_token_storage.dart';

class tayseerSocketHelper {
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  Completer<bool>? _connectionCompleter;

  /// الـ token المعتمد للـ session الحالية
  String? _authorizedToken;

  // ══════════════════════════════════════════════════════════════════════════
  // LISTENERS MAP
  // ══════════════════════════════════════════════════════════════════════════

  final Map<String, Map<String, Function(dynamic)>> _listeners = {};

  // ══════════════════════════════════════════════════════════════════════════
  // RECONNECT CALLBACKS — Map بدل callback واحد
  // كل مكتبة/cubit يسجل نفسه بـ ID مستقل
  // ══════════════════════════════════════════════════════════════════════════

  final Map<String, Function()> _reconnectCallbacks = {};

  void addReconnectCallback(String id, Function() callback) {
    _reconnectCallbacks[id] = callback;
    log('🔄 [Socket] addReconnectCallback: $id');
  }

  void removeReconnectCallback(String id) {
    _reconnectCallbacks.remove(id);
    log('🔕 [Socket] removeReconnectCallback: $id');
  }

  void _notifyReconnected() {
    log(
      '🔄 [Socket] notifying ${_reconnectCallbacks.length} reconnect callbacks',
    );
    final callbacks = Map<String, Function()>.from(_reconnectCallbacks);
    callbacks.forEach((id, cb) {
      try {
        cb();
      } catch (e) {
        log('❌ [Socket] error in reconnect callback "$id": $e');
      }
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGE QUEUE — رسائل تتبعت وهو مقطوع
  // ══════════════════════════════════════════════════════════════════════════

  final List<_QueuedMessage> _messageQueue = [];

  void _flushMessageQueue() {
    if (_messageQueue.isEmpty) return;
    log('📤 [Socket] flushing ${_messageQueue.length} queued messages');
    final toSend = List<_QueuedMessage>.from(_messageQueue);
    _messageQueue.clear();
    for (final msg in toSend) {
      _emitNow(msg.event, msg.data, msg.callback);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LEGACY CALLBACKS (backward compat)
  // ══════════════════════════════════════════════════════════════════════════

  Function()? onDisconnected;
  Function(String message)? onError;

  // ✅ backward compat — يكتب على الـ map بـ key ثابت
  // لا يزال يشتغل لكن الأفضل استخدام addReconnectCallback
  set onReconnected(Function()? cb) {
    if (cb == null) {
      _reconnectCallbacks.remove('_legacy_');
    } else {
      _reconnectCallbacks['_legacy_'] = cb;
    }
  }

  Function()? get onReconnected => _reconnectCallbacks['_legacy_'];

  void setErrorCallback(Function(String message) callback) {
    onError = callback;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONNECT
  // ══════════════════════════════════════════════════════════════════════════

  bool get isConnected => _isConnected && _socket != null && _socket!.connected;

  Future<bool> connect({String? token}) async {
    if (_socket != null && _socket!.connected) {
      log('🔁 [Socket] Already connected');
      _isConnected = true;
      return true;
    }

    if (_isConnecting && _connectionCompleter != null) {
      log('⏳ [Socket] Connection already in progress, waiting...');
      return await _connectionCompleter!.future;
    }

    _isConnecting = true;
    _connectionCompleter = Completer<bool>();

    final String? tokenToUse = token ?? _authorizedToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      log('❌ [Socket] No authorized token — refusing to connect');
      _isConnecting = false;
      _connectionCompleter?.complete(false);
      return false;
    }

    log('🔧 [Socket] Initializing socket connection...');

    _socket = IO.io(
      kbaseUrlebSocket,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableReconnection() // ✅ نتحكم في الـ reconnect يدوياً
          .enableForceNew()
          .setExtraHeaders({'Authorization': 'Bearer $tokenToUse'})
          .build(),
    );

    _socket!.onConnect((_) {
      log('✅ [Socket] Connected');
      final wasReconnect =
          _isConnected == false && (_connectionCompleter?.isCompleted ?? true);
      _isConnected = true;
      _isConnecting = false;

      if (!(_connectionCompleter?.isCompleted ?? true)) {
        // الـ connect الأول
        _connectionCompleter?.complete(true);
      } else if (wasReconnect) {
        // reconnect بعد انقطاع — أعد تسجيل الـ socket listeners ثم أبلّغ الـ callbacks
        log('🔄 [Socket] Reconnected — re-registering socket listeners');
        _reRegisterSocketListeners();
        _notifyReconnected();
        _flushMessageQueue();
      }
    });

    _socket!.onConnectError((error) {
      log('❌ [Socket] Connection Error: $error');
      _isConnecting = false;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(false);
      }

      // ✅ JWT expired on the socket — fetch a fresh token and reconnect
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('jwt expired') ||
          errorStr.contains('authentication error') ||
          errorStr.contains('token expired') ||
          errorStr.contains('unauthorized')) {
        log('🔑 [Socket] JWT expired on connect — attempting token refresh...');
        _handleJwtExpiry();
        return;
      }

      onError?.call('فشل الاتصال: $error');
      // ✅ retry بعد فشل الاتصال
      _scheduleReconnect();
    });

    // ✅ تسجيل الـ fail listener عبر الـ map
    _listeners['fail'] ??= {};
    _listeners['fail']!['_global_fail_handler'] = (data) {
      log('⚠️ [Socket] fail: $data');
      onError?.call(
        data is Map ? (data['message'] ?? 'فشل غير معروف') : 'فشل غير معروف',
      );
    };
    _socket!.on('fail', (data) {
      final listeners = Map<String, Function(dynamic)>.from(
        _listeners['fail'] ?? {},
      );
      listeners.forEach((id, cb) {
        try {
          cb(data);
        } catch (e) {
          log('❌ [Socket] Error in fail listener "$id": $e');
        }
      });
    });

    _socket!.on('error', (error) {
      log('❌ [Socket] Error: $error');
      _isConnecting = false;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(false);
      }

      // ✅ JWT expired sent as 'error' event (not connect_error) by this server
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('jwt expired') ||
          errorStr.contains('authentication error') ||
          errorStr.contains('token expired') ||
          errorStr.contains('unauthorized')) {
        log('🔑 [Socket] JWT error event — attempting token refresh...');
        _handleJwtExpiry();
        return;
      }

      onError?.call('خطأ: $error');
    });

    _socket!.onDisconnect((reason) {
      log('❌ [Socket] Disconnected. Reason: $reason');
      _isConnected = false;
      onError?.call('تم قطع الاتصال: $reason');
      onDisconnected?.call();

      // ✅ auto-reconnect لو الانقطاع مش بسبب logout
      if (_authorizedToken != null && _authorizedToken!.isNotEmpty) {
        _scheduleReconnect();
      }
    });

    _socket!.onAny((dynamic event, [dynamic data]) {
      try {
        if (data != null) {
          log('📡 [Socket] Event: $event , Data: $data');
        } else {
          log('📡 [Socket] Event: $event (no data)');
        }
      } catch (e) {
        log('⚠️ [Socket] Error in onAny: $e');
      }
    });

    log('🚀 [Socket] Attempting to connect...');
    _socket!.connect();

    try {
      final bool connected = await _connectionCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('⏱️ [Socket] Connection timeout');
          onError?.call('انتهت مهلة الاتصال');
          _isConnecting = false;
          _scheduleReconnect();
          return false;
        },
      );
      if (connected) _isConnected = true;
      _isConnecting = false;
      return connected;
    } catch (e) {
      log('❌ [Socket] Error during connection: $e');
      _isConnecting = false;
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RECONNECT — يستخدم نفس الـ socket instance بدل إنشاء واحد جديد
  // ══════════════════════════════════════════════════════════════════════════

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  void _scheduleReconnect() {
    if (_authorizedToken == null || _authorizedToken!.isEmpty) return;
    if (_isConnecting) return;
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectAttempts++;
    if (_reconnectAttempts > _maxReconnectAttempts) {
      log('⚠️ [Socket] Max reconnect attempts reached');
      _reconnectAttempts = 0;
      return;
    }

    // Exponential backoff: 2s, 4s, 8s... max 30s
    final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(2, 30));
    log(
      '🔄 [Socket] Scheduling reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts)',
    );

    _reconnectTimer = Timer(delay, () {
      if (_isConnected || _isConnecting) return;
      if (_authorizedToken == null || _authorizedToken!.isEmpty) return;

      log('🔄 [Socket] Attempting reconnect...');

      if (_socket != null) {
        // ✅ استخدم نفس الـ socket instance — الـ listeners موجودة عليه
        _isConnecting = true;
        _connectionCompleter = Completer<bool>();
        _socket!.connect();

        // timeout للـ reconnect attempt
        _connectionCompleter!.future
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                _isConnecting = false;
                _scheduleReconnect();
                return false;
              },
            )
            .then((connected) {
              _isConnecting = false;
              if (connected) {
                _reconnectAttempts = 0;
              }
            })
            .catchError((_) {
              _isConnecting = false;
            });
      } else {
        // الـ socket اتدمر (مثلاً بعد reset) — اعمل واحد جديد
        connect(token: _authorizedToken);
      }
    });
  }

  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // JWT EXPIRY — call /auth/refresh-token then reconnect with fresh token
  // Same logic as AuthInterceptor but for the socket layer.
  // ══════════════════════════════════════════════════════════════════════════

  bool _isHandlingJwtExpiry = false;

  /// Called when the socket server rejects the connection with a JWT error.
  /// Calls /auth/refresh-token directly (bare Dio, no interceptors to avoid
  /// circular calls), saves the new tokens, then reconnects the socket.
  Future<void> _handleJwtExpiry() async {
    if (_isHandlingJwtExpiry) return;
    _isHandlingJwtExpiry = true;

    try {
      log('🔑 [Socket] JWT error — refreshing token...');
      final newToken = await _doTokenRefresh();
      if (newToken != null) {
        log('✅ [Socket] JWT refreshed — reconnecting...');
        _authorizedToken = newToken;
        await resetAndConnect(token: newToken);
      } else {
        log('❌ [Socket] JWT refresh failed — no refresh token or API error');
        onError?.call('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
      }
    } on DioException catch (e) {
      log('❌ [Socket] JWT refresh DioException: ${e.response?.statusCode}');
      onError?.call('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى');
    } catch (e) {
      log('❌ [Socket] JWT refresh error: $e');
      _scheduleReconnect();
    } finally {
      _isHandlingJwtExpiry = false;
    }
  }

  /// Shared helper: calls /auth/refresh-token and persists the new tokens.
  /// Returns the new accessToken, or null on failure.
  Future<String?> _doTokenRefresh() async {
    final refreshToken = await SecureTokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final bareDio = Dio();
    final response = await bareDio.post(
      '$kbaseUrl/auth/refresh-token',
      data: {'refreshToken': refreshToken},
      options: Options(headers: {'lang': selectedLanguage ?? 'ar'}),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      final data = response.data['data'] as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String;
      final newRefresh = data['refreshToken'] as String;

      await SecureTokenStorage.saveBothTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ktoken, newAccess);

      return newAccess;
    }
    return null;
  }

  /// Connect with automatic JWT refresh on first failure.
  /// Use this from feature cubits instead of [resetAndConnect] directly.
  /// Returns true when fully connected and ready to use.
  Future<bool> connectWithAutoRefresh({required String token}) async {
    // First attempt with the given token
    final connected = await resetAndConnect(token: token);
    if (connected) return true;

    // First attempt failed — try refreshing the JWT once and retry
    log('🔑 [Socket] connectWithAutoRefresh: retrying after JWT refresh...');
    try {
      final newToken = await _doTokenRefresh();
      if (newToken != null) {
        log(
          '✅ [Socket] connectWithAutoRefresh: JWT refreshed, reconnecting...',
        );
        return await resetAndConnect(token: newToken);
      }
    } on DioException catch (e) {
      log(
        '❌ [Socket] connectWithAutoRefresh refresh error: ${e.response?.statusCode}',
      );
    } catch (e) {
      log('❌ [Socket] connectWithAutoRefresh error: $e');
    }
    return false;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RE-REGISTER SOCKET LISTENERS بعد reconnect
  // ══════════════════════════════════════════════════════════════════════════

  /// بعد الـ reconnect، الـ socket.io بيحتفظ بالـ listeners تلقائياً
  /// لكن لو الـ socket اتعمل جديد (بعد reset)، لازم نعيد تسجيلهم
  void _reRegisterSocketListeners() {
    if (_socket == null) return;
    log('🔄 [Socket] Re-registering ${_listeners.length} event listeners');
    for (final event in _listeners.keys) {
      if (event == 'fail') continue; // fail بيتسجل في connect()
      _setupSocketListener(event);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SEND — مع queue للرسائل المعلقة
  // ══════════════════════════════════════════════════════════════════════════

  /// الأحداث اللي ما تتحفظش في الـ queue (مثلاً join/leave/typing)
  static const _noQueueEvents = {
    'joinChatRoom',
    'leaveChatRoom',
    'typingStatus',
  };

  void send(String event, dynamic data, Function(dynamic ack)? callback) {
    if (_isConnected && _socket != null && _socket!.connected) {
      _emitNow(event, data, callback);
    } else {
      // ✅ احفظ الرسالة في الـ queue لو مش join/leave/typing
      if (!_noQueueEvents.contains(event)) {
        log('📦 [Socket] Queuing message for event "$event" (not connected)');
        _messageQueue.add(
          _QueuedMessage(event: event, data: data, callback: callback),
        );
      } else {
        log(
          '⚠️ [Socket] Dropping "$event" — socket not connected (no queue for this event)',
        );
      }
    }
  }

  void _emitNow(String event, dynamic data, Function(dynamic ack)? callback) {
    if (_socket == null) return;
    if (callback != null) {
      _socket!.emitWithAck(event, data, ack: callback);
    } else {
      _socket!.emit(event, data);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LISTEN WITH ID
  // ══════════════════════════════════════════════════════════════════════════

  void listen(String event, Function(dynamic data) callback) {
    if (_socket == null) {
      log('⚠️ [Socket] Socket not initialized yet');
      return;
    }
    log('📡 [Socket] Listening to $event (legacy method)');
    _socket!.off(event);
    _socket!.on(event, (data) {
      log('📥 [Socket] Received "$event": $data');
      callback(data);
    });
  }

  void listenWithId(
    String event,
    String listenerId,
    Function(dynamic data) callback,
  ) {
    if (_socket == null) {
      log('⚠️ [Socket] Socket not initialized yet');
      return;
    }

    _listeners[event] ??= {};
    _listeners[event]![listenerId] = callback;

    log(
      '📡 [Socket] Added listener "$listenerId" for "$event" (total: ${_listeners[event]!.length})',
    );

    if (_listeners[event]!.length == 1) {
      _setupSocketListener(event);
    }
  }

  void _setupSocketListener(String event) {
    if (_socket == null) return;
    _socket!.off(event);
    _socket!.on(event, (data) {
      log(
        '📥 [Socket] Received "$event" → ${_listeners[event]?.length ?? 0} listeners',
      );
      final listeners = Map<String, Function(dynamic)>.from(
        _listeners[event] ?? {},
      );
      listeners.forEach((listenerId, callback) {
        try {
          callback(data);
        } catch (e) {
          log('❌ [Socket] Error in listener "$listenerId": $e');
        }
      });
    });
  }

  void offWithId(String event, String listenerId) {
    if (_listeners[event] == null) return;
    _listeners[event]!.remove(listenerId);
    log(
      '🔕 [Socket] Removed listener "$listenerId" for "$event" (remaining: ${_listeners[event]!.length})',
    );

    if (_listeners[event]!.isEmpty) {
      _socket?.off(event);
      _listeners.remove(event);
    }
  }

  void renameListenerId(String oldId, String newId) {
    _listeners.forEach((event, listeners) {
      if (listeners.containsKey(oldId)) {
        listeners[newId] = listeners.remove(oldId)!;
        log('🔄 [Socket] Renamed listener "$oldId" → "$newId" for "$event"');
      }
    });
  }

  void offAllForListener(String listenerId) {
    log('🔕 [Socket] Removing all listeners for "$listenerId"');
    final eventsToClean = <String>[];
    _listeners.forEach((event, listeners) {
      if (listeners.containsKey(listenerId)) {
        listeners.remove(listenerId);
        if (listeners.isEmpty) eventsToClean.add(event);
      }
    });
    for (final event in eventsToClean) {
      _socket?.off(event);
      _listeners.remove(event);
    }
  }

  void off(String event) {
    _socket?.off(event);
    _listeners.remove(event);
  }

  bool hasListener(String event, String listenerId) {
    return _listeners[event]?.containsKey(listenerId) ?? false;
  }

  int getListenerCount(String event) {
    return _listeners[event]?.length ?? 0;
  }

  void debugPrintListeners() {
    log('📊 ===== Current Listeners =====');
    _listeners.forEach((event, listeners) {
      log('📡 Event: $event');
      listeners.forEach((id, _) => log('   └── $id'));
    });
    log('📊 ==============================');
  }

  void listenOnce(String event, Function(dynamic) callback) {
    if (_socket == null) return;
    void handler(dynamic data) {
      callback(data);
      _socket!.off(event, handler);
    }

    _socket!.on(event, handler);
  }

  void setOnDisconnectedCallback(Function() callback) {
    onDisconnected = callback;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DISCONNECT / RESET
  // ══════════════════════════════════════════════════════════════════════════

  void disconnect() {
    _cancelReconnect();
    if (_socket != null) {
      _socket!.disconnect();
      _isConnected = false;
    }
  }

  void clearAuthorizedToken() {
    _authorizedToken = null;
    log('🔑 [Socket] Authorized token cleared');
  }

  void clearAllListeners() {
    _listeners.forEach((event, _) => _socket?.off(event));
    _listeners.clear();
    log('🧹 [Socket] Cleared all listeners');
  }

  /// Full reset — call on logout
  void reset() {
    _cancelReconnect();
    _listeners.clear();
    _reconnectCallbacks.clear();
    _messageQueue.clear();
    _isConnecting = false;
    _connectionCompleter = null;
    _authorizedToken = null;
    onDisconnected = null;
    onError = null;
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.destroy();
      _socket!.clearListeners();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    log('🔄 [Socket] Socket helper reset');
  }

  /// Full reset then connect for the new user
  Future<bool> resetAndConnect({String? token}) async {
    if (token == null || token.isEmpty) {
      log(
        '❌ [Socket] resetAndConnect called without explicit token — aborting',
      );
      _authorizedToken = null;
      return false;
    }

    _cancelReconnect();
    _listeners.clear();
    _reconnectCallbacks.clear();
    _messageQueue.clear();
    _isConnecting = false;
    _connectionCompleter = null;
    _authorizedToken = token;

    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.destroy();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    log('🔄 [Socket] Fully reset — connecting for new user...');

    await Future.delayed(const Duration(milliseconds: 500));
    return await connect(token: _authorizedToken);
  }

  void dispose() {
    _cancelReconnect();
    clearAllListeners();
    _reconnectCallbacks.clear();
    _messageQueue.clear();
    disconnect();
    _socket?.dispose();
    _socket = null;
    log('🗑️ [Socket] Socket helper disposed');
  }
}

// ══════════════════════════════════════════════════════════════════════════
// QUEUED MESSAGE MODEL
// ══════════════════════════════════════════════════════════════════════════

class _QueuedMessage {
  final String event;
  final dynamic data;
  final Function(dynamic)? callback;

  const _QueuedMessage({
    required this.event,
    required this.data,
    this.callback,
  });
}
