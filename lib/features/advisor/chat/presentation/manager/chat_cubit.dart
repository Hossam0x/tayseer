import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:tayseer/core/database/entities/chat_room_entity.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/local/chat_local_datasource.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';

import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_v2.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_state.dart';
import 'package:tayseer/my_import.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required this.localDataSource, required this.chatRepoV2})
    : super(ChatState()) {
    _listenerId =
        'ChatCubit_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
    log('🆔 ChatCubit created with ID: $_listenerId');
  }

  final ChatLocalDataSource localDataSource;
  final ChatRepoV2 chatRepoV2;
  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  // ✅ Unique Listener ID لهذا الـ Cubit
  late final String _listenerId;

  // ✅ Track currently active chat room to prevent unread count increment
  String? _activeChatRoomId;

  /// Set the currently active (opened) chat room
  void setActiveChatRoom(String? chatRoomId) {
    _activeChatRoomId = chatRoomId;
    log('🎯 [$_listenerId] Active chat room set to: $chatRoomId');
  }

  /// ✅ Safe emit
  void _safeEmit(ChatState newState) {
    if (!isClosed) {
      emit(newState);
    } else {
      log('⚠️ [$_listenerId] Attempted to emit after close');
    }
  }

  /// ✅ Local-first: Load from cache first, then sync with server
  void fetchChatRooms() async {
    _safeEmit(state.copyWith(getallchatrooms: CubitStates.loading));

    // Step 1: Load from local cache first
    try {
      final cachedRooms = await localDataSource.getAllChatRooms();
      if (cachedRooms.isNotEmpty && !isClosed) {
        log(
          '📦 [$_listenerId] Loaded ${cachedRooms.length} chat rooms from cache',
        );
        _safeEmit(
          state.copyWith(
            getallchatrooms: CubitStates.success,
            chatRoom: ChatRoomsData(
              rooms: cachedRooms,
              pagination: Pagination(
                totalCount: cachedRooms.length,
                totalPages: 1,
                currentPage: 1,
                pageSize: cachedRooms.length,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      log('⚠️ [$_listenerId] Failed to load from cache: $e');
    }

    // Step 2: Fetch from server and update cache
    final result = await chatRepoV2.getAllChatRooms();

    if (isClosed) return;

    result.fold(
      (failure) {
        // Only show failure if we don't have cached data
        if (state.chatRoom == null || state.chatRoom!.rooms.isEmpty) {
          _safeEmit(
            state.copyWith(
              getallchatrooms: CubitStates.failure,
              errorMessage: failure,
            ),
          );
        }
        log('❌ [$_listenerId] Failed to fetch from server: $failure');
      },
      (chatRoomsResponse) async {
        log(
          '🌐 [$_listenerId] Fetched ${chatRoomsResponse.data.rooms.length} chat rooms from server',
        );

        // Update local cache
        try {
          final entities = chatRoomsResponse.data.rooms
              .map((room) => ChatRoomEntity.fromChatRoom(room))
              .toList();
          await localDataSource.upsertChatRooms(entities);
          log('💾 [$_listenerId] Saved ${entities.length} chat rooms to cache');
        } catch (e) {
          log('⚠️ [$_listenerId] Failed to save to cache: $e');
        }

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
    // ✅ FIX: Don't count as unread if user is viewing this chat
    final isCurrentlyViewing = chatRoomId == _activeChatRoomId;
    final shouldCountUnread = !isMe && !isCurrentlyViewing;
    final newChatRoom = ChatRoom(
      id: chatRoomId,
      users: [sender], // المرسل كـ user
      lastMessage: lastMessage,
      lastMessageAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      status: 'active',
      sender: sender,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      unreadCount: shouldCountUnread ? 1 : 0,
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

        // ✅ FIX: Don't increment unread count if:
        // 1. Message is from me (isMe)
        // 2. User is currently viewing this chat (chatRoomId == _activeChatRoomId)
        final isCurrentlyViewing = chatRoomId == _activeChatRoomId;
        final shouldIncrementUnread = !isMe && !isCurrentlyViewing;
        final newUnreadCount = shouldIncrementUnread
            ? room.unreadCount + 1
            : room.unreadCount;

        if (!isMe && isCurrentlyViewing) {
          log(
            '🔕 [$_listenerId] Skipping unread increment - user is viewing this chat',
          );
        }

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

  /// تحديث حالة الحظر للشات
  void updateBlockStatus(String chatRoomId, bool isBlocked) {
    if (isClosed) return;

    final currentChatData = state.chatRoom;
    if (currentChatData == null) return;

    final updatedRooms = currentChatData.rooms.map((room) {
      if (room.id == chatRoomId) {
        return room.copyWith(isBlocked: isBlocked);
      }
      return room;
    }).toList();

    _safeEmit(
      state.copyWith(chatRoom: currentChatData.copyWith(rooms: updatedRooms)),
    );

    log('✅ [$_listenerId] Updated block status for $chatRoomId: $isBlocked');
  }

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing ChatCubit...');

    // ✅ إزالة كل الـ listeners الخاصة بهذا الـ Cubit فقط
    socketHelper.offAllForListener(_listenerId);

    log('✅ [$_listenerId] ChatCubit closed and cleaned up');

    return super.close();
  }

  void markMessageRed(String chatRoomId) {
    socketHelper.send('mark_messages_read', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ mark_messages_read ACK: $ack');
    });
  }

  /// ✅ Delete chat room (Local-first: delete from cache immediately, then sync with server)
  Future<void> deleteChatRoom(String chatRoomId) async {
    log('🗑️ [$_listenerId] Deleting chat room: $chatRoomId');

    // Step 1: Save current state for rollback if needed
    final previousChatData = state.chatRoom;

    // Step 2: Remove from UI immediately (optimistic update)
    if (previousChatData != null) {
      final updatedRooms = previousChatData.rooms
          .where((room) => room.id != chatRoomId)
          .toList();

      _safeEmit(
        state.copyWith(
          chatRoom: previousChatData.copyWith(rooms: updatedRooms),
        ),
      );
      log('✅ [$_listenerId] Chat room removed from UI');
    }

    // Step 3: Delete from local cache
    try {
      await localDataSource.deleteChatRoom(chatRoomId);
      log('✅ [$_listenerId] Chat room deleted from local cache');
    } catch (e) {
      log('⚠️ [$_listenerId] Failed to delete from cache: $e');
    }

    // Step 4: Delete from server (in background)
    final result = await chatRepoV2.deleteChatRoom(chatRoomId);

    result.fold(
      (error) {
        log('❌ [$_listenerId] Failed to delete from server: $error');
        // Optionally: rollback UI if server deletion fails
        // For now, we keep the optimistic deletion
      },
      (success) {
        log('✅ [$_listenerId] Chat room deleted from server');
      },
    );
  }

  /// ✅ Block user from chat list (Local-first)
  Future<Either<String, String>> blockUser({
    required String blockedId,
    required String chatRoomId,
  }) async {
    log('🚫 [$_listenerId] Blocking user: $blockedId from chat list');

    // Step 1: Update UI immediately (optimistic)
    updateBlockStatus(chatRoomId, true);

    // Step 2: Call server
    final result = await chatRepoV2.blockUser(blockedId: blockedId);

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Block user failed: $error');
        // Rollback on failure
        updateBlockStatus(chatRoomId, false);
        return Left(error);
      },
      (successMessage) {
        log('✅ [$_listenerId] Block user success: $successMessage');
        return Right(successMessage);
      },
    );
  }

  /// ✅ Unblock user from chat list (Local-first)
  Future<Either<String, String>> unblockUser({
    required String blockedId,
    required String chatRoomId,
  }) async {
    log('✅ [$_listenerId] Unblocking user: $blockedId from chat list');

    // Step 1: Update UI immediately (optimistic)
    updateBlockStatus(chatRoomId, false);

    // Step 2: Call server
    final result = await chatRepoV2.unblockUser(blockedId: blockedId);

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Unblock user failed: $error');
        // Rollback on failure
        updateBlockStatus(chatRoomId, true);
        return Left(error);
      },
      (successMessage) {
        log('✅ [$_listenerId] Unblock user success: $successMessage');
        return Right(successMessage);
      },
    );
  }

  /// ✅ Archive chat room (Local-first: remove from UI, then call API)
  Future<void> archiveChatRoom(String chatRoomId) async {
    log('📦 [$_listenerId] Archiving chat room: $chatRoomId');

    // Save current state for rollback if needed
    final previousChatData = state.chatRoom;

    // Remove from UI immediately (optimistic update)
    if (previousChatData != null) {
      final updatedRooms = previousChatData.rooms
          .where((room) => room.id != chatRoomId)
          .toList();

      _safeEmit(
        state.copyWith(
          chatRoom: previousChatData.copyWith(rooms: updatedRooms),
        ),
      );
      log('✅ [$_listenerId] Chat room removed from UI');
    }

    // Call API to archive on server
    final result = await chatRepoV2.archiveChatRoom(chatRoomId);

    result.fold(
      (error) {
        log('❌ [$_listenerId] Failed to archive on server: $error');
        // Optionally rollback UI on failure
      },
      (success) {
        log('✅ [$_listenerId] Chat room archived on server');
      },
    );
  }
}
