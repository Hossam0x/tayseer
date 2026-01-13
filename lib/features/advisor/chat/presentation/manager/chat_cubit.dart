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

  late final String _listenerId;

  String? _activeChatRoomId;

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

  /// ✅ دمج قوائم الشاتات مع إزالة التكرار (محسّن)
  List<ChatRoom> _mergeAndSortRooms(
    List<ChatRoom> existing,
    List<ChatRoom> incoming,
  ) {
    final Map<String, ChatRoom> roomMap = {};

    // إضافة الشاتات الموجودة
    for (final room in existing) {
      roomMap[room.id] = room;
    }

    // إضافة/تحديث الشاتات الجديدة
    for (final room in incoming) {
      final existingRoom = roomMap[room.id];
      if (existingRoom == null) {
        roomMap[room.id] = room;
      } else {
        final existingTime = existingRoom.lastMessageAt ?? DateTime(1970);
        final incomingTime = room.lastMessageAt ?? DateTime(1970);

        if (incomingTime.isAfter(existingTime) ||
            incomingTime == existingTime) {
          // ✅ الأحدث يكسب، لكن نحتفظ ببعض القيم
          roomMap[room.id] = room.copyWith(
            unreadCount: room.unreadCount > existingRoom.unreadCount
                ? room.unreadCount
                : existingRoom.unreadCount,
            isBlocked: room.isBlocked || existingRoom.isBlocked,
          );
        } else {
          // ✅ الـ existing أحدث
          roomMap[room.id] = existingRoom.copyWith(
            isBlocked: room.isBlocked || existingRoom.isBlocked,
          );
        }
      }
    }

    // ترتيب حسب آخر رسالة
    final merged = roomMap.values.toList();
    merged.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime(1970);
      final bTime = b.lastMessageAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    return merged;
  }

  void fetchChatRooms() async {
    log('🔄 [$_listenerId] Starting fetchChatRooms');

    final existingRooms = state.chatRoom?.rooms ?? [];

    _safeEmit(state.copyWith(getallchatrooms: CubitStates.loading));

    // Step 1: Load from local cache first
    List<ChatRoom> cachedRooms = [];
    try {
      cachedRooms = await localDataSource.getAllChatRooms();
      if (cachedRooms.isNotEmpty && !isClosed) {
        log(
          '📦 [$_listenerId] Loaded ${cachedRooms.length} chat rooms from cache',
        );

        final mergedRooms = _mergeAndSortRooms(existingRooms, cachedRooms);

        _safeEmit(
          state.copyWith(
            getallchatrooms: CubitStates.success,
            chatRoom: ChatRoomsData(
              rooms: mergedRooms,
              pagination: Pagination(
                totalCount: mergedRooms.length,
                totalPages: 1,
                currentPage: 1,
                pageSize: mergedRooms.length,
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

        try {
          final entities = chatRoomsResponse.data.rooms
              .map((room) => ChatRoomEntity.fromChatRoom(room))
              .toList();
          await localDataSource.upsertChatRooms(entities);
          log('💾 [$_listenerId] Saved ${entities.length} chat rooms to cache');
        } catch (e) {
          log('⚠️ [$_listenerId] Failed to save to cache: $e');
        }

        final currentRooms = state.chatRoom?.rooms ?? [];
        final serverRooms = chatRoomsResponse.data.rooms;
        final mergedRooms = _mergeAndSortRooms(currentRooms, serverRooms);

        _safeEmit(
          state.copyWith(
            getallchatrooms: CubitStates.success,
            chatRoom: chatRoomsResponse.data.copyWith(rooms: mergedRooms),
          ),
        );

        log('✅ [$_listenerId] Final rooms count: ${mergedRooms.length}');
      },
    );
  }

  void listenToNewMessages() {
    log('🎧 [$_listenerId] Setting up new_message listener for chat list');

    socketHelper.listenWithId('new_message', _listenerId, (data) {
      _handleNewMessageForChatList(data);
    });
  }

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

      if (chatRoomId == null || chatRoomId.isEmpty) {
        log('❌ [$_listenerId] chatRoomId is null or empty');
        return;
      }

      final currentChatData = state.chatRoom;
      final chatRoomExists =
          currentChatData?.rooms.any((room) => room.id == chatRoomId) ?? false;

      if (chatRoomExists) {
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

    final currentRooms = state.chatRoom?.rooms ?? [];
    if (currentRooms.any((room) => room.id == chatRoomId)) {
      log(
        '⚠️ [$_listenerId] ChatRoom $chatRoomId already exists, updating instead',
      );
      _updateChatRoomLastMessage(
        chatRoomId: chatRoomId,
        messageId: messageId,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isMe: isMe,
        senderId: senderId,
        senderName: senderName,
        senderType: senderType,
        messageType: messageType,
      );
      return;
    }

    final sender = ChatUser(
      id: senderId,
      name: senderName,
      image: senderImage.isNotEmpty ? senderImage : null,
      userType: senderType,
    );

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

    final isCurrentlyViewing = chatRoomId == _activeChatRoomId;
    final shouldCountUnread = !isMe && !isCurrentlyViewing;
    final newChatRoom = ChatRoom(
      id: chatRoomId,
      users: [sender],
      lastMessage: lastMessage,
      lastMessageAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      status: 'active',
      sender: sender,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      unreadCount: shouldCountUnread ? 1 : 0,
    );

    _saveChatRoomToCache(newChatRoom);

    final currentChatData = state.chatRoom;

    if (currentChatData == null) {
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
      final updatedRooms = _mergeAndSortRooms(currentChatData.rooms, [
        newChatRoom,
      ]);

      final updatedPagination = Pagination(
        totalCount: updatedRooms.length,
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

  Future<void> _saveChatRoomToCache(ChatRoom chatRoom) async {
    try {
      final entity = ChatRoomEntity.fromChatRoom(chatRoom);
      await localDataSource.upsertChatRoom(entity);
      log('💾 [$_listenerId] Saved ChatRoom ${chatRoom.id} to cache');
    } catch (e) {
      log('⚠️ [$_listenerId] Failed to save ChatRoom to cache: $e');
    }
  }

  String _extractContent(dynamic content) {
    if (content == null) return '';
    if (content is String) {
      return content;
    } else if (content is List && content.isNotEmpty) {
      return content.first.toString();
    }
    return '';
  }

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

    ChatRoom? updatedRoom;
    final updatedRooms = currentRooms.map((room) {
      if (room.id == chatRoomId) {
        log('✅ [$_listenerId] Updating lastMessage for room: $chatRoomId');

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

        updatedRoom = room.copyWith(
          lastMessage: updatedLastMessage,
          lastMessageAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
          unreadCount: newUnreadCount,
        );

        return updatedRoom!;
      }
      return room;
    }).toList();

    if (updatedRoom != null) {
      _saveChatRoomToCache(updatedRoom!);
    }

    updatedRooms.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime(1970);
      final bTime = b.lastMessageAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    _safeEmit(
      state.copyWith(chatRoom: currentChatData.copyWith(rooms: updatedRooms)),
    );

    log('✅ [$_listenerId] Chat list updated successfully');
  }

  // ✅ إصلاح: حفظ في الـ Cache
  void markChatAsRead(String chatRoomId) {
    if (isClosed) return;

    final currentChatData = state.chatRoom;
    if (currentChatData == null) return;

    ChatRoom? updatedRoom;
    final updatedRooms = currentChatData.rooms.map((room) {
      if (room.id == chatRoomId) {
        updatedRoom = room.copyWith(unreadCount: 0);
        return updatedRoom!;
      }
      return room;
    }).toList();

    _safeEmit(
      state.copyWith(chatRoom: currentChatData.copyWith(rooms: updatedRooms)),
    );

    // ✅ حفظ في الـ Cache
    if (updatedRoom != null) {
      _saveChatRoomToCache(updatedRoom!);
    }

    log('✅ [$_listenerId] Marked chat $chatRoomId as read');
  }

  // ✅ إصلاح: حفظ في الـ Cache
  void updateBlockStatus(String chatRoomId, bool isBlocked) {
    if (isClosed) return;

    final currentChatData = state.chatRoom;
    if (currentChatData == null) return;

    ChatRoom? updatedRoom;
    final updatedRooms = currentChatData.rooms.map((room) {
      if (room.id == chatRoomId) {
        updatedRoom = room.copyWith(isBlocked: isBlocked);
        return updatedRoom!;
      }
      return room;
    }).toList();

    _safeEmit(
      state.copyWith(chatRoom: currentChatData.copyWith(rooms: updatedRooms)),
    );

    // ✅ حفظ في الـ Cache
    if (updatedRoom != null) {
      _saveChatRoomToCache(updatedRoom!);
    }

    log('✅ [$_listenerId] Updated block status for $chatRoomId: $isBlocked');
  }

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing ChatCubit...');
    socketHelper.offAllForListener(_listenerId);
    log('✅ [$_listenerId] ChatCubit closed and cleaned up');
    return super.close();
  }

  void markMessageRed(String chatRoomId) {
    socketHelper.send('mark_messages_read', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ mark_messages_read ACK: $ack');
    });
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    log('🗑️ [$_listenerId] Deleting chat room: $chatRoomId');

    final previousChatData = state.chatRoom;

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

    try {
      await localDataSource.deleteChatRoom(chatRoomId);
      log('✅ [$_listenerId] Chat room deleted from local cache');
    } catch (e) {
      log('⚠️ [$_listenerId] Failed to delete from cache: $e');
    }

    final result = await chatRepoV2.deleteChatRoom(chatRoomId);

    result.fold(
      (error) => log('❌ [$_listenerId] Failed to delete from server: $error'),
      (success) => log('✅ [$_listenerId] Chat room deleted from server'),
    );
  }

  Future<Either<String, String>> blockUser({
    required String blockedId,
    required String chatRoomId,
  }) async {
    log('🚫 [$_listenerId] Blocking user: $blockedId from chat list');

    updateBlockStatus(chatRoomId, true);

    final result = await chatRepoV2.blockUser(blockedId: blockedId);

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Block user failed: $error');
        updateBlockStatus(chatRoomId, false);
        return Left(error);
      },
      (successMessage) {
        log('✅ [$_listenerId] Block user success: $successMessage');
        return Right(successMessage);
      },
    );
  }

  Future<Either<String, String>> unblockUser({
    required String blockedId,
    required String chatRoomId,
  }) async {
    log('✅ [$_listenerId] Unblocking user: $blockedId from chat list');

    updateBlockStatus(chatRoomId, false);

    final result = await chatRepoV2.unblockUser(blockedId: blockedId);

    return result.fold(
      (error) {
        log('❌ [$_listenerId] Unblock user failed: $error');
        updateBlockStatus(chatRoomId, true);
        return Left(error);
      },
      (successMessage) {
        log('✅ [$_listenerId] Unblock user success: $successMessage');
        return Right(successMessage);
      },
    );
  }

  Future<void> archiveChatRoom(String chatRoomId) async {
    log('📦 [$_listenerId] Archiving chat room: $chatRoomId');

    final previousChatData = state.chatRoom;

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

    final result = await chatRepoV2.archiveChatRoom(chatRoomId);

    result.fold(
      (error) => log('❌ [$_listenerId] Failed to archive on server: $error'),
      (success) => log('✅ [$_listenerId] Chat room archived on server'),
    );
  }
}
