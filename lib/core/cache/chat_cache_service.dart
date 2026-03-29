import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tayseer/features/advisor/chat/data/model/chat_message/chat_messages_response.dart';
import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';

/// نظام كاش بسيط للشات باستخدام Hive
class ChatCacheService {
  static const String _chatRoomsBoxName = 'chat_rooms_cache';
  static const String _messagesBoxName = 'chat_messages_cache';

  Box<String>? _chatRoomsBox;
  Box<String>? _messagesBox;

  /// Initialize Hive boxes
  Future<void> init() async {
    _chatRoomsBox = await Hive.openBox<String>(_chatRoomsBoxName);
    _messagesBox = await Hive.openBox<String>(_messagesBoxName);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHAT ROOMS CACHE
  // ══════════════════════════════════════════════════════════════════════════

  /// حفظ قائمة الشاتات (للـ advisor)
  Future<void> saveChatRooms({
    required String userId,
    required List<AdvisorChatRoomModel> chatRooms,
  }) async {
    if (_chatRoomsBox == null) return;

    final key = 'chat_rooms_$userId';
    final jsonList = chatRooms.map((room) => room.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await _chatRoomsBox!.put(key, jsonString);
  }

  /// جلب قائمة الشاتات من الكاش (للـ advisor)
  List<AdvisorChatRoomModel>? getCachedChatRooms({required String userId}) {
    if (_chatRoomsBox == null) return null;

    final key = 'chat_rooms_$userId';
    final jsonString = _chatRoomsBox!.get(key);

    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => AdvisorChatRoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// حفظ قائمة الشاتات (للـ user)
  Future<void> saveUserChatRooms({
    required String userId,
    required List<AdvisorChatRoomModel> chatRooms,
  }) async {
    if (_chatRoomsBox == null) return;

    final key = 'user_chat_rooms_$userId';
    final jsonList = chatRooms.map((room) => room.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await _chatRoomsBox!.put(key, jsonString);
  }

  /// جلب قائمة الشاتات من الكاش (للـ user)
  List<AdvisorChatRoomModel>? getCachedUserChatRooms({required String userId}) {
    if (_chatRoomsBox == null) return null;

    final key = 'user_chat_rooms_$userId';
    final jsonString = _chatRoomsBox!.get(key);

    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => AdvisorChatRoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MESSAGES CACHE
  // ══════════════════════════════════════════════════════════════════════════

  /// حفظ رسائل chat room معين
  Future<void> saveMessages({
    required String chatRoomId,
    required List<ChatMessage> messages,
  }) async {
    if (_messagesBox == null) return;

    final key = 'messages_$chatRoomId';
    final jsonList = messages.map((msg) => msg.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await _messagesBox!.put(key, jsonString);
  }

  /// جلب رسائل chat room من الكاش
  List<ChatMessage>? getCachedMessages({required String chatRoomId}) {
    if (_messagesBox == null) return null;

    final key = 'messages_$chatRoomId';
    final jsonString = _messagesBox!.get(key);

    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEAR CACHE
  // ══════════════════════════════════════════════════════════════════════════

  /// مسح كل الكاش
  Future<void> clearAllCache() async {
    await _chatRoomsBox?.clear();
    await _messagesBox?.clear();
  }

  /// مسح كاش chat room معين
  Future<void> clearChatRoomCache({required String chatRoomId}) async {
    final key = 'messages_$chatRoomId';
    await _messagesBox?.delete(key);
  }

  /// مسح كاش الشاتات لمستخدم معين
  Future<void> clearUserChatRoomsCache({required String userId}) async {
    await _chatRoomsBox?.delete('chat_rooms_$userId');
    await _chatRoomsBox?.delete('user_chat_rooms_$userId');
  }
}
