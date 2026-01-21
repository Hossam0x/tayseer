import 'dart:async';
import 'dart:developer';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tayseer/core/shared/network/local_network.dart';

class tayseerSocketHelper {
  IO.Socket? _socket;
  bool _isConnected = false;
  Completer<bool>? _connectionCompleter;

  final Map<String, Map<String, Function(dynamic)>> _listeners = {};

  bool get isConnected => _isConnected;
  Function()? onDisconnected;
  Function(String message)? onError;

  void setErrorCallback(Function(String message) callback) {
    onError = callback;
  }

  Future<bool> connect() async {
    if (_socket != null && _socket!.connected) {
      log('🔁 Already connected');
      return true;
    }

    _connectionCompleter = Completer<bool>();
    log('🔧 Initializing socket connection...');

    final String? token = CachNetwork.getStringData(key: 'token');

    log('Token: $token');

    if (token == null) {
      log('❌ No token found in SharedPreferences');
      onError?.call('لا يوجد توكين محفوظه');
      _connectionCompleter?.complete(false);
      return false;
    }

    _socket = IO.io(
      'https://tayser-app.net',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': token})
          .build(),
    );

    _socket!.onConnect((_) {
      log('✅ Connected to tayseer Game Socket');
      _isConnected = true;
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(true);
      }
    });

    _socket!.onConnectError((error) {
      log('❌ Connection Error: $error');
      onError?.call('فشل الاتصال: $error');
      if (!(_connectionCompleter?.isCompleted ?? true)) {
        _connectionCompleter?.complete(false);
      }
    });

    _socket!.on('fail', (data) {
      log('⚠️ fail: $data');
      onError?.call(data['message'] ?? 'فشل غير معروف');
    });

    _socket!.on('error', (error) {
      log('❌ Socket Error: $error');
      onError?.call('خطأ: $error');
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
      return await _connectionCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('⏱️ Connection timeout');
          onError?.call('انتهت مهلة الاتصال');
          return false;
        },
      );
    } catch (e) {
      log('❌ Error during connection: $e');
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

  /// ✅ تنظيف كل الـ listeners
  void clearAllListeners() {
    _listeners.forEach((event, _) {
      _socket?.off(event);
    });
    _listeners.clear();
    log('🧹 Cleared all listeners');
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
