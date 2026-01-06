import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_state.dart';
import 'package:tayseer/my_import.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required this.chatRepo}) : super(ChatState()) {
    _listenerId =
        'ChatCubit_${DateTime.now().millisecondsSinceEpoch}_${hashCode}';
    log('🆔 ChatCubit created with ID: $_listenerId');
  }

  final ChatRepo chatRepo;
  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  // ✅ Unique Listener ID لهذا الـ Cubit
  late final String _listenerId;

  /// ✅ Safe emit
  void _safeEmit(ChatState newState) {
    if (!isClosed) {
      emit(newState);
    } else {
      log('⚠️ [$_listenerId] Attempted to emit after close');
    }
  }

  void fetchChatRooms() async {
    _safeEmit(state.copyWith(getallchatrooms: CubitStates.loading));

    final result = await chatRepo.getAllChatRooms();

    if (isClosed) return;

    result.fold(
      (failure) => _safeEmit(
        state.copyWith(
          getallchatrooms: CubitStates.failure,
          errorMessage: failure,
        ),
      ),
      (chatRoomsResponse) {
        _safeEmit(
          state.copyWith(
            getallchatrooms: CubitStates.success,
            chatRoom: chatRoomsResponse.data,
          ),
        );
      },
    );
  }

  /// ✅ الاستماع للرسائل الجديدة وتحديث آخر رسالة
  void listenToNewMessages() {
    log('🎧 [$_listenerId] Setting up new_message listener for chat list');

    socketHelper.listenWithId('new_message', _listenerId, (data) {
      _handleNewMessageForChatList(data);
    });
  }

  /// ✅ معالجة الرسالة الجديدة لتحديث قائمة الشات
  void _handleNewMessageForChatList(dynamic data) {
    if (isClosed) {
      log('⚠️ [$_listenerId] Received message but Cubit is closed - ignoring');
      return;
    }

    log('📨 [$_listenerId] Processing new message for chat list update');

    try {
      final chatRoomId = data['chatRoomId']?.toString();
      final content = data['content'];
      final createdAt = data['createdAt']?.toString() ?? '';
      final updatedAt = data['updatedAt']?.toString() ?? '';
      final isMe = data['isMe'] ?? false;
      final senderId = data['senderId']?.toString() ?? '';
      final senderName = data['senderName']?.toString() ?? '';
      final senderType = data['senderType']?.toString() ?? '';
      final senderImage = data['senderImage']?.toString() ?? '';
      final messageType = data['messageType']?.toString() ?? 'text';
      final messageId = data['id']?.toString() ?? '';

      if (chatRoomId == null) {
        log('❌ [$_listenerId] chatRoomId is null');
        return;
      }

      // ✅ التحقق إذا كان الـ chatRoomId موجود في القائمة
      final currentChatData = state.chatRoom;
      final chatRoomExists =
          currentChatData?.rooms.any((room) => room.id == chatRoomId) ?? false;

      if (chatRoomExists) {
        // ✅ الشات موجود - نحدث الـ lastMessage
        log('📝 [$_listenerId] ChatRoom exists, updating lastMessage');
        _updateChatRoomLastMessage(
          chatRoomId: chatRoomId,
          messageId: messageId,
          content: _extractContent(content),
          createdAt: createdAt,
          updatedAt: updatedAt,
          isMe: isMe,
          senderId: senderId,
          senderName: senderName,
          senderType: senderType,
          messageType: messageType,
        );
      } else {
        // ✅ الشات جديد - نضيفه في القائمة
        log('🆕 [$_listenerId] New ChatRoom detected, adding to list');
        _addNewChatRoom(
          chatRoomId: chatRoomId,
          messageId: messageId,
          content: _extractContent(content),
          createdAt: createdAt,
          updatedAt: updatedAt,
          isMe: isMe,
          senderId: senderId,
          senderName: senderName,
          senderType: senderType,
          senderImage: senderImage,
          messageType: messageType,
        );
      }
    } catch (e, stackTrace) {
      log('❌ [$_listenerId] Error processing new message: $e');
      log('StackTrace: $stackTrace');
    }
  }

  /// ✅ إضافة ChatRoom جديد في القائمة
  void _addNewChatRoom({
    required String chatRoomId,
    required String messageId,
    required String content,
    required String createdAt,
    required String updatedAt,
    required bool isMe,
    required String senderId,
    required String senderName,
    required String senderType,
    required String senderImage,
    required String messageType,
  }) {
    log('🆕 [$_listenerId] Adding new ChatRoom: $chatRoomId');

    // إنشاء الـ Sender
    final sender = ChatUser(
      id: senderId,
      name: senderName,
      image: senderImage.isNotEmpty ? senderImage : null,
      userType: senderType,
    );

    // إنشاء الـ LastMessage
    final lastMessage = LastMessage(
      id: messageId,
      chatRoom: chatRoomId,
      sender: senderId,
      senderType: senderType,
      content: content,
      messageType: messageType,
      senderName: senderName,
      timeAgo: 'الآن',
      createdAt: DateTime.tryParse(createdAt),
      updatedAt: DateTime.tryParse(updatedAt),
    );

    // إنشاء الـ ChatRoom الجديد
    final newChatRoom = ChatRoom(
      id: chatRoomId,
      users: [sender], // المرسل كـ user
      lastMessage: lastMessage,
      lastMessageAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      status: 'active',
      sender: sender,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      unreadCount: isMe ? 0 : 1, // لو الرسالة مش مني يبقى فيه 1 unread
    );

    // الحصول على القائمة الحالية
    final currentChatData = state.chatRoom;

    if (currentChatData == null) {
      // لو مفيش data أصلاً، ننشئ واحدة جديدة
      log('📝 [$_listenerId] No existing chat data, creating new');
      final newChatData = ChatRoomsData(
        rooms: [newChatRoom],
        pagination: Pagination(
          totalCount: 1,
          totalPages: 1,
          currentPage: 1,
          pageSize: 10,
        ),
      );

      _safeEmit(
        state.copyWith(
          getallchatrooms: CubitStates.success,
          chatRoom: newChatData,
        ),
      );
    } else {
      // إضافة الـ ChatRoom الجديد في أول القائمة
      final updatedRooms = [newChatRoom, ...currentChatData.rooms];

      // تحديث الـ pagination
      final updatedPagination = Pagination(
        totalCount: currentChatData.pagination.totalCount + 1,
        totalPages: currentChatData.pagination.totalPages,
        currentPage: currentChatData.pagination.currentPage,
        pageSize: currentChatData.pagination.pageSize,
      );

      _safeEmit(
        state.copyWith(
          chatRoom: ChatRoomsData(
            rooms: updatedRooms,
            pagination: updatedPagination,
          ),
        ),
      );
    }

    log('✅ [$_listenerId] New ChatRoom added successfully');
  }

  /// استخراج المحتوى (سواء String أو List)
  String _extractContent(dynamic content) {
    if (content == null) return '';
    if (content is String) {
      return content;
    } else if (content is List && content.isNotEmpty) {
      return content.first.toString();
    }
    return '';
  }

  /// ✅ تحديث آخر رسالة في ChatRoom معين
  void _updateChatRoomLastMessage({
    required String chatRoomId,
    required String messageId,
    required String content,
    required String createdAt,
    required String updatedAt,
    required bool isMe,
    required String senderId,
    required String senderName,
    required String senderType,
    required String messageType,
  }) {
    final currentChatData = state.chatRoom;
    if (currentChatData == null) {
      log('❌ [$_listenerId] No chat data available');
      return;
    }

    final currentRooms = currentChatData.rooms;
    if (currentRooms.isEmpty) {
      log('❌ [$_listenerId] No chat rooms available');
      return;
    }

    // البحث عن الـ ChatRoom وتحديثه
    final updatedRooms = currentRooms.map((room) {
      if (room.id == chatRoomId) {
        log('✅ [$_listenerId] Updating lastMessage for room: $chatRoomId');

        // إنشاء LastMessage جديدة
        final updatedLastMessage = LastMessage(
          id: messageId,
          chatRoom: chatRoomId,
          sender: senderId,
          senderType: senderType,
          content: content,
          messageType: messageType,
          senderName: senderName,
          timeAgo: 'الآن',
          createdAt: DateTime.tryParse(createdAt),
          updatedAt: DateTime.tryParse(updatedAt),
        );

        // تحديث الـ unreadCount فقط لو الرسالة مش مني
        final newUnreadCount = isMe ? room.unreadCount : room.unreadCount + 1;

        return room.copyWith(
          lastMessage: updatedLastMessage,
          lastMessageAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
          unreadCount: newUnreadCount,
        );
      }
      return room;
    }).toList();

    // ✅ إعادة ترتيب الشات حسب آخر رسالة (الأحدث في الأول)
    updatedRooms.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime(1970);
      final bTime = b.lastMessageAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    // تحديث الـ State
    _safeEmit(
      state.copyWith(chatRoom: currentChatData.copyWith(rooms: updatedRooms)),
    );

    log('✅ [$_listenerId] Chat list updated successfully');
  }

  void markChatAsRead(String chatRoomId) {
    if (isClosed) return;

    final currentChatData = state.chatRoom;
    if (currentChatData == null) return;

    final updatedRooms = currentChatData.rooms.map((room) {
      if (room.id == chatRoomId) {
        return room.copyWith(unreadCount: 0);
      }
      return room;
    }).toList();

    _safeEmit(
      state.copyWith(chatRoom: currentChatData.copyWith(rooms: updatedRooms)),
    );

    log('✅ [$_listenerId] Marked chat $chatRoomId as read');
  }

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing ChatCubit...');

    // ✅ إزالة كل الـ listeners الخاصة بهذا الـ Cubit فقط
    socketHelper.offAllForListener(_listenerId);

    log('✅ [$_listenerId] ChatCubit closed and cleaned up');

    return super.close();
  }

  markMessageRed(String chatRoomId) {
    socketHelper.send('mark_messages_read', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ mark_messages_read ACK: $ack');
    });
  }
}
