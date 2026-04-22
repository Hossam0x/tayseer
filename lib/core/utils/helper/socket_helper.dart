import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tayseer/core/shared/network/local_network.dart';

class tayseerSocketHelper {
  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  Completer<bool>? _connectionCompleter;
  // ✅ الـ token المعتمد للـ session الحالية — يُعيَّن في resetAndConnect
  // يمنع أي connect() تاني من استخدام token قديم من الـ cache
  String? _authorizedToken;

  final Map<String, Map<String, Function(dynamic)>> _listeners = {};

  bool get isConnected => _isConnected && _socket != null && _socket!.connected;
  Function()? onDisconnected;
  Function(String message)? onError;

  void setErrorCallback(Function(String message) callback) {
    onError = callback;
  }

  Future<bool> connect({String? token}) async {
    if (_socket != null && _socket!.connected) {
      log('🔁 Already connected');
      _isConnected = true;
      return true;
    }

    // Guard: if a connection attempt is already in progress, wait for it
    if (_isConnecting && _connectionCompleter != null) {
      log('⏳ Connection already in progress, waiting...');
      return await _connectionCompleter!.future;
    }

    _isConnecting = true;
    _connectionCompleter = Completer<bool>();
    log('🔧 Initializing socket connection...');

    // ✅ الأولوية: token ممرر صراحةً > _authorizedToken > NOTHING
    // لا نقرأ من الـ cache أبداً — التوكن لازم يجي من الـ caller صراحةً
    final String? tokenToUse = token ?? _authorizedToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      log('❌ No authorized token — refusing to connect');
      _isConnecting = false;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(false);
      }
      return false;
    }

    _socket = IO.io(
      'https://tayser-app.net',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableReconnection()
          .enableForceNew()
          .setExtraHeaders({'Authorization': 'Bearer $tokenToUse'})
          .build(),
    );

    _socket!.onConnect((_) {
      log('✅ Connected to tayseer Game Socket');
      _isConnected = true;
      _isConnecting = false;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(true);
      }
    });

    _socket!.onConnectError((error) {
      log('❌ Connection Error: $error');
      onError?.call('فشل الاتصال: $error');
      _isConnecting = false;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(false);
      }
    });

    // ✅ Register via listenWithId so it's not wiped by legacy listen() calls
    _listeners['fail'] ??= {};
    _listeners['fail']!['_global_fail_handler'] = (data) {
      log('⚠️ fail: $data');
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
          log('❌ Error in fail listener "$id": $e');
        }
      });
    });

    _socket!.on('error', (error) {
      log('❌ Socket Error: $error');
      onError?.call('خطأ: $error');
      _isConnecting = false;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(false);
      }
    });

    _socket!.onDisconnect((reason) {
      log('❌ Disconnected from tayseer Game Socket. Reason: $reason');
      _isConnected = false;
      onError?.call('تم قطع الاتصال: $reason');
      onDisconnected?.call();
    });

    _socket!.onAny((dynamic event, [dynamic data]) {
      try {
        if (data != null) {
          log('📡 Event from server: $event , Data: $data');
        } else {
          log('📡 Event from server: $event (no data)');
        }
      } catch (e, s) {
        log('⚠️ Error while handling onAny event: $e');
        log('StackTrace: $s');
      }
    });

    log('🚀 Attempting to connect...');
    _socket!.connect();

    try {
      final bool connected = await _connectionCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('⏱️ Connection timeout');
          onError?.call('انتهت مهلة الاتصال');
          _isConnecting = false;
          return false;
        },
      );
      if (connected) _isConnected = true;
      _isConnecting = false;
      return connected;
    } catch (e) {
      log('❌ Error during connection: $e');
      _isConnecting = false;
      return false;
    }
  }

  void send(String event, dynamic data, Function(dynamic ack)? callback) {
    if (_isConnected && _socket != null) {
      _socket!.emit(event, data);
    } else {
      log('⚠️ Socket not connected yet');
    }
  }

  /// ✅ الـ listen القديم (للتوافق مع الكود القديم)
  /// ⚠️ لا ينصح باستخدامه - استخدم listenWithId بدلاً منه
  void listen(String event, Function(dynamic data) callback) {
    if (_socket == null) {
      log('⚠️ Socket not initialized yet');
      return;
    }
    log('📡 Listening to $event (legacy method)');
    _socket!.off(event);
    _socket!.on(event, (data) {
      log('📥 Received event "$event" with data: $data');
      callback(data);
    });
  }

  /// ✅ الـ listen الجديد مع Listener ID
  /// كل listener له ID فريد، وممكن نشيله لوحده من غير ما نأثر على باقي الـ listeners
  void listenWithId(
    String event,
    String listenerId,
    Function(dynamic data) callback,
  ) {
    if (_socket == null) {
      log('⚠️ Socket not initialized yet');
      return;
    }

    // إضافة الـ listener للـ Map
    _listeners[event] ??= {};
    _listeners[event]![listenerId] = callback;

    log('📡 Added listener "$listenerId" for event "$event"');
    log('📊 Total listeners for "$event": ${_listeners[event]!.length}');

    // لو أول listener للـ event ده، نعمل setup للـ socket listener
    if (_listeners[event]!.length == 1) {
      _setupSocketListener(event);
    }
  }

  /// ✅ Setup الـ socket listener للـ event
  void _setupSocketListener(String event) {
    _socket!.off(event); // نشيل أي listener قديم
    _socket!.on(event, (data) {
      log('📥 Received event "$event" with data: $data');
      log('📊 Broadcasting to ${_listeners[event]?.length ?? 0} listeners');

      // نعمل copy من الـ listeners عشان لو حد اتشال وإحنا بنلف
      final listeners = Map<String, Function(dynamic)>.from(
        _listeners[event] ?? {},
      );

      listeners.forEach((listenerId, callback) {
        try {
          log('📤 Calling listener "$listenerId"');
          callback(data);
        } catch (e) {
          log('❌ Error in listener "$listenerId": $e');
        }
      });
    });
  }

  /// ✅ إزالة listener معين بالـ ID
  void offWithId(String event, String listenerId) {
    if (_listeners[event] == null) {
      log('⚠️ No listeners found for event "$event"');
      return;
    }

    _listeners[event]!.remove(listenerId);
    log('🔕 Removed listener "$listenerId" for event "$event"');
    log('📊 Remaining listeners for "$event": ${_listeners[event]!.length}');

    // لو مفيش listeners تاني للـ event ده، نشيل الـ socket listener
    if (_listeners[event]!.isEmpty) {
      _socket?.off(event);
      _listeners.remove(event);
      log('🔕 Removed socket listener for event "$event" (no more listeners)');
    }
  }

  /// ✅ Rename all listeners from oldId to newId across all events
  void renameListenerId(String oldId, String newId) {
    _listeners.forEach((event, listeners) {
      if (listeners.containsKey(oldId)) {
        listeners[newId] = listeners.remove(oldId)!;
        log('🔄 Renamed listener "$oldId" → "$newId" for event "$event"');
      }
    });
  }

  /// ✅ إزالة كل الـ listeners لـ listener ID معين (في كل الـ events)
  void offAllForListener(String listenerId) {
    log('🔕 Removing all listeners for "$listenerId"');

    final eventsToClean = <String>[];

    _listeners.forEach((event, listeners) {
      if (listeners.containsKey(listenerId)) {
        listeners.remove(listenerId);
        log('🔕 Removed "$listenerId" from event "$event"');

        if (listeners.isEmpty) {
          eventsToClean.add(event);
        }
      }
    });

    // تنظيف الـ events الفاضية
    for (final event in eventsToClean) {
      _socket?.off(event);
      _listeners.remove(event);
      log('🔕 Removed socket listener for event "$event" (no more listeners)');
    }
  }

  /// ✅ إزالة كل الـ listeners لـ event معين
  void off(String event) {
    _socket?.off(event);
    _listeners.remove(event);
    log('🔕 Removed all listeners for event "$event"');
  }

  /// ✅ التحقق من وجود listener معين
  bool hasListener(String event, String listenerId) {
    return _listeners[event]?.containsKey(listenerId) ?? false;
  }

  /// ✅ الحصول على عدد الـ listeners لـ event معين
  int getListenerCount(String event) {
    return _listeners[event]?.length ?? 0;
  }

  /// ✅ طباعة كل الـ listeners (للـ debugging)
  void debugPrintListeners() {
    log('📊 ===== Current Listeners =====');
    _listeners.forEach((event, listeners) {
      log('📡 Event: $event');
      listeners.forEach((id, _) {
        log('   └── $id');
      });
    });
    log('📊 ==============================');
  }

  void listenOnce(String event, Function(dynamic) callback) {
    if (_socket == null) {
      log('⚠️ Socket not initialized yet');
      return;
    }

    void handler(dynamic data) {
      callback(data);
      _socket!.off(event, handler);
    }

    _socket!.on(event, handler);
  }

  void setOnDisconnectedCallback(Function() callback) {
    onDisconnected = callback;
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _isConnected = false;
    }
  }

  /// ✅ Full reset — call on logout to destroy socket and clear all listeners
  void reset() {
    _listeners.clear(); // clear our map only (don't touch socket listeners yet)
    _isConnecting = false;
    _connectionCompleter = null;
    _authorizedToken = null; // ✅ امسح الـ authorized token عند الـ logout
    if (_socket != null) {
      _socket!.disconnect(); // sends disconnect packet → triggers onDisconnect
      _socket!.destroy(); // stops any reconnection attempts
      _socket!.clearListeners(); // now safe to clear socket-level handlers
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    log('🔄 Socket helper reset');
  }

  /// ✅ امسح الـ authorized token فقط (بدون reset كامل)
  /// يُستدعى قبل الـ logout عشان أي connect() تاني مش يستخدم token قديم
  void clearAuthorizedToken() {
    _authorizedToken = null;
    log('🔑 Authorized token cleared');
  }

  /// ✅ تنظيف كل الـ listeners
  void clearAllListeners() {
    _listeners.forEach((event, _) {
      _socket?.off(event);
    });
    _listeners.clear();
    log('🧹 Cleared all listeners');
  }

  /// Full reset then connect for the new user — token must be passed explicitly
  Future<bool> resetAndConnect({String? token}) async {
    // ✅ لو مفيش token صريح → فشل آمن، مش نقرأ من الـ cache
    if (token == null || token.isEmpty) {
      log('❌ resetAndConnect called without explicit token — aborting');
      _authorizedToken = null;
      return false;
    }

    _listeners.clear();
    _isConnecting = false;
    _connectionCompleter = null;
    // ✅ احفظ الـ token المعتمد للـ session الجديدة
    _authorizedToken = token;

    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.destroy();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    log('🔄 Socket fully reset — connecting for new user...');

    await Future.delayed(const Duration(milliseconds: 500));

    return await connect(token: _authorizedToken);
  }

  /// ✅ Dispose كامل
  void dispose() {
    clearAllListeners();
    disconnect();
    _socket?.dispose();
    _socket = null;
    log('🗑️ Socket helper disposed');
  }
}
