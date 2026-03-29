import 'dart:developer';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';
import 'package:tayseer/features/user/my_space/data/repo/my_space_repo.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/my_space/my_space_state.dart';
import 'package:tayseer/my_import.dart';

class MySpaceCubit extends Cubit<MySpaceState> {
  final MySpaceRepo mySpaceRepo;
  final ChatCacheService _cacheService = getIt<ChatCacheService>();
  final tayseerSocketHelper socketHelper = getIt.get<tayseerSocketHelper>();

  late final String _listenerId;
  String? _activeChatRoomId;

  MySpaceCubit(this.mySpaceRepo) : super(const MySpaceState()) {
    _listenerId =
        'MySpaceCubit_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
    log('🆔 MySpaceCubit created with ID: $_listenerId');
  }

  void _safeEmit(MySpaceState newState) {
    if (!isClosed) {
      emit(newState);
    } else {
      log('⚠️ [$_listenerId] Attempted to emit after close');
    }
  }

  void setActiveChatRoom(String? chatRoomId) {
    _activeChatRoomId = chatRoomId;
    log('🎯 [$_listenerId] Active chat room set to: $chatRoomId');
  }

  Future<void> getAdvisorChat() async {
    final userId = kCurrentUserData?.id;
    if (userId == null) {
      _safeEmit(
        state.copyWith(
          advisorChatState: CubitStates.failure,
          errorMessage: 'User not logged in',
        ),
      );
      return;
    }

    // 1. عرض الكاش فوراً لو موجود
    final cachedRooms = _cacheService.getCachedUserChatRooms(userId: userId);
    if (cachedRooms != null && cachedRooms.isNotEmpty) {
      // تحويل الكاش لـ AdvisorChatModel
      final cachedModel = AdvisorChatModel(
        success: true,
        message: 'Cached data',
        data: AdvisorChatData(
          chatRooms: cachedRooms,
          pagination: PaginationModel(
            totalCount: cachedRooms.length,
            totalPages: 1,
            currentPage: 1,
            pageSize: cachedRooms.length,
          ),
        ),
      );
      
      _safeEmit(
        state.copyWith(
          advisorChatState: CubitStates.success,
          advisorChatModel: cachedModel,
        ),
      );
    } else {
      _safeEmit(state.copyWith(advisorChatState: CubitStates.loading));
    }

    CubitStates.printState(
      stateName: "MySpaceCubit - getAdvisorChat",
      state: CubitStates.loading,
    );

    // 2. جلب من السيرفر وتحديث
    final result = await mySpaceRepo.getadvisorchat();

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: "MySpaceCubit - getAdvisorChat",
          state: CubitStates.failure,
        );

        // لو فشل وما عندناش كاش، نعرض error
        if (cachedRooms == null || cachedRooms.isEmpty) {
          _safeEmit(
            state.copyWith(
              advisorChatState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        }
      },
      (advisorChatModel) async {
        CubitStates.printState(
          stateName: "MySpaceCubit - getAdvisorChat",
          state: CubitStates.success,
        );

        _safeEmit(
          state.copyWith(
            advisorChatState: CubitStates.success,
            advisorChatModel: advisorChatModel,
          ),
        );

        // 3. حفظ في الكاش
        await _cacheService.saveUserChatRooms(
          userId: userId,
          chatRooms: advisorChatModel.data.chatRooms,
        );
      },
    );
  }

  /// Listen to new messages from socket
  bool _isListening = false;

  void listenToNewMessages() {
    if (_isListening) {
      log('⚠️ [$_listenerId] Already listening to new messages');
      return;
    }

    _isListening = true;
    log('🎧 [$_listenerId] Setting up new_message listener for user chat list');

    socketHelper.listenWithId('newMessage', _listenerId, (data) {
      _handleNewMessageForChatList(data);
    });
  }

  /// Handle new message and update chat list
  void _handleNewMessageForChatList(dynamic data) {
    if (isClosed) {
      log('⚠️ [$_listenerId] Received message but Cubit is closed - ignoring');
      return;
    }

    log('📨 [$_listenerId] Processing new message for user chat list update');
    log('📨 [$_listenerId] Raw data: $data');

    try {
      final messageData = data['message'];
      if (messageData == null) return;
      
      final chatRoomId = messageData['chatRoomId']?.toString();
      final content = messageData['content'];
      final createdAt = messageData['sentAt']?.toString() ?? messageData['createdAt']?.toString() ?? '';
      final updatedAt = messageData['updatedAt']?.toString() ?? '';
      final isMe = messageData['isMe'] ?? false;
      final senderName = messageData['senderName']?.toString() ?? '';
      final messageType = messageData['contentType']?.toString() ?? messageData['messageType']?.toString() ?? 'text';
      final messageId = messageData['id']?.toString() ?? messageData['_id']?.toString() ?? '';

      log(
        '📨 [$_listenerId] Extracted - chatRoomId: $chatRoomId, messageId: $messageId',
      );

      if (chatRoomId == null) {
        log('❌ [$_listenerId] chatRoomId is null');
        return;
      }

      final currentChatData = state.advisorChatModel?.data;
      log(
        '📨 [$_listenerId] Current chat data exists: ${currentChatData != null}',
      );
      log(
        '📨 [$_listenerId] Total chat rooms: ${currentChatData?.chatRooms.length ?? 0}',
      );

      final chatRoomExists =
          currentChatData?.chatRooms.any((room) => room.id == chatRoomId) ??
          false;

      log('📨 [$_listenerId] ChatRoom exists: $chatRoomExists');

      if (chatRoomExists) {
        log('📝 [$_listenerId] ChatRoom exists, updating lastMessage');
        _updateChatRoomLastMessage(
          chatRoomId: chatRoomId,
          messageId: messageId,
          content: _extractContent(content),
          createdAt: createdAt,
          updatedAt: updatedAt,
          isMe: isMe,
          senderName: senderName,
          messageType: messageType,
        );
      } else {
        log(
          '🆕 [$_listenerId] New ChatRoom detected (will be fetched on next refresh)',
        );
        // Optionally trigger a refresh to fetch new chat rooms
        // getAdvisorChat();
      }
    } catch (e, stackTrace) {
      log('❌ [$_listenerId] Error processing new message: $e');
      log('StackTrace: $stackTrace');
    }
  }

  /// Update last message in a chat room
  void _updateChatRoomLastMessage({
    required String chatRoomId,
    required String messageId,
    required String content,
    required String createdAt,
    required String updatedAt,
    required bool isMe,
    required String senderName,
    required String messageType,
  }) {
    final currentChatData = state.advisorChatModel?.data;
    if (currentChatData == null) {
      log('❌ [$_listenerId] No chat data available');
      return;
    }

    final currentRooms = currentChatData.chatRooms;
    if (currentRooms.isEmpty) {
      log('❌ [$_listenerId] No chat rooms available');
      return;
    }

    final updatedRooms = currentRooms.map((room) {
      if (room.id == chatRoomId) {
        log('✅ [$_listenerId] Updating lastMessage for room: $chatRoomId');

        final updatedLastMessage = LastMessageModel(
          id: messageId.isNotEmpty
              ? messageId
              : (room.lastMessage?.id ?? ''), // Use new ID if available
          sender: room.lastMessage?.sender ?? '',
          senderType: room.lastMessage?.senderType ?? '',
          content: content,
          messageType: messageType,
          chatRoom: chatRoomId,
          createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
          senderName: senderName,
          timeAgo: 'الآن',
        );

        // Don't increment unread count if user is viewing this chat
        final isCurrentlyViewing = chatRoomId == _activeChatRoomId;
        final shouldIncrementUnread = !isMe && !isCurrentlyViewing;
        final newUnreadCount = shouldIncrementUnread
            ? room.unreadCount + 1
            : room.unreadCount;

        if (!isMe && isCurrentlyViewing) {
          log(
            '🔕 [$_listenerId] Skipping unread increment - user is viewing this chat',
          );
          // ✅ مهم جداً: نبعت للسيرفر إننا قرينا الرسالة دي حالاً
          markMessageAsReadOnSocket(chatRoomId);
        }

        return AdvisorChatRoomModel(
          id: room.id,
          isBlocked: room.isBlocked,
          isHaveSession: room.isHaveSession,
          users: room.users,
          lastMessage: updatedLastMessage,
          lastMessageAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
          status: room.status,
          sender: room.sender,
          createdAt: room.createdAt,
          updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
          unreadCount: newUnreadCount,
        );
      }
      return room;
    }).toList();

    // Sort by latest message
    updatedRooms.sort((a, b) {
      final aTime = a.lastMessageAt ?? DateTime(1970);
      final bTime = b.lastMessageAt ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });

    final updatedData = AdvisorChatData(
      chatRooms: updatedRooms,
      pagination: currentChatData.pagination,
    );

    final updatedModel = AdvisorChatModel(
      success: state.advisorChatModel?.success ?? true,
      message: state.advisorChatModel?.message ?? '',
      data: updatedData,
    );

    _safeEmit(
      state.copyWith(
        advisorChatModel: updatedModel,
        lastUpdateTime: DateTime.now(), // Force rebuild
      ),
    );

    log('✅ [$_listenerId] User chat list updated successfully');
  }

  /// Extract content from message
  String _extractContent(dynamic content) {
    if (content == null) return '';
    if (content is String) {
      return content;
    } else if (content is List && content.isNotEmpty) {
      final first = content.first;
      if (first is Map) {
        return first['media']?.toString() ?? first['url']?.toString() ?? first.toString();
      }
      return first.toString();
    }
    return '';
  }

  /// Mark chat as read
  void markChatAsRead(String chatRoomId) {
    if (isClosed) return;

    final currentChatData = state.advisorChatModel?.data;
    if (currentChatData == null) return;

    final updatedRooms = currentChatData.chatRooms.map((room) {
      if (room.id == chatRoomId) {
        return AdvisorChatRoomModel(
          id: room.id,
          isBlocked: room.isBlocked,
          isHaveSession: room.isHaveSession,
          users: room.users,
          lastMessage: room.lastMessage,
          lastMessageAt: room.lastMessageAt,
          status: room.status,
          sender: room.sender,
          createdAt: room.createdAt,
          updatedAt: room.updatedAt,
          unreadCount: 0,
        );
      }
      return room;
    }).toList();

    final updatedData = AdvisorChatData(
      chatRooms: updatedRooms,
      pagination: currentChatData.pagination,
    );

    final updatedModel = AdvisorChatModel(
      success: state.advisorChatModel?.success ?? true,
      message: state.advisorChatModel?.message ?? '',
      data: updatedData,
    );

    _safeEmit(
      state.copyWith(
        advisorChatModel: updatedModel,
        lastUpdateTime: DateTime.now(),
      ),
    );

    log('✅ [$_listenerId] Marked chat $chatRoomId as read');
  }

  /// Send mark as read to socket
  void markMessageAsReadOnSocket(String chatRoomId) {
    socketHelper.send('mark_messages_read', {'chatRoomId': chatRoomId}, (ack) {
      log('✅ [$_listenerId] mark_messages_read ACK: $ack');
    });
  }

  /// Delete chat room (optimistic update)
  Future<bool> deleteChatRoom(String chatRoomId) async {
    final currentChatData = state.advisorChatModel?.data;
    if (currentChatData == null) return false;

    // Optimistic: remove immediately from list
    final originalRooms = currentChatData.chatRooms;
    final updatedRooms = originalRooms
        .where((r) => r.id != chatRoomId)
        .toList();
    _safeEmit(
      state.copyWith(
        advisorChatModel: AdvisorChatModel(
          success: state.advisorChatModel!.success,
          message: state.advisorChatModel!.message,
          data: AdvisorChatData(
            chatRooms: updatedRooms,
            pagination: currentChatData.pagination,
          ),
        ),
        lastUpdateTime: DateTime.now(),
      ),
    );

    final result = await mySpaceRepo.deleteChatRoom(chatRoomId);
    return result.fold((failure) {
      // Revert on failure
      _safeEmit(
        state.copyWith(
          advisorChatModel: AdvisorChatModel(
            success: state.advisorChatModel!.success,
            message: state.advisorChatModel!.message,
            data: AdvisorChatData(
              chatRooms: originalRooms,
              pagination: currentChatData.pagination,
            ),
          ),
          lastUpdateTime: DateTime.now(),
          errorMessage: failure.message,
        ),
      );
      return false;
    }, (_) => true);
  }

  /// Archive chat room (optimistic update)
  Future<bool> archiveChatRoom(String chatRoomId) async {
    final currentChatData = state.advisorChatModel?.data;
    if (currentChatData == null) return false;

    // Optimistic: remove immediately from list
    final originalRooms = currentChatData.chatRooms;
    final updatedRooms = originalRooms
        .where((r) => r.id != chatRoomId)
        .toList();
    _safeEmit(
      state.copyWith(
        advisorChatModel: AdvisorChatModel(
          success: state.advisorChatModel!.success,
          message: state.advisorChatModel!.message,
          data: AdvisorChatData(
            chatRooms: updatedRooms,
            pagination: currentChatData.pagination,
          ),
        ),
        lastUpdateTime: DateTime.now(),
      ),
    );

    final result = await mySpaceRepo.archiveChatRoom(chatRoomId);
    return result.fold((failure) {
      // Revert on failure
      _safeEmit(
        state.copyWith(
          advisorChatModel: AdvisorChatModel(
            success: state.advisorChatModel!.success,
            message: state.advisorChatModel!.message,
            data: AdvisorChatData(
              chatRooms: originalRooms,
              pagination: currentChatData.pagination,
            ),
          ),
          lastUpdateTime: DateTime.now(),
          errorMessage: failure.message,
        ),
      );
      return false;
    }, (_) => true);
  }

  /// Reset State
  void resetState() {
    _safeEmit(const MySpaceState());
  }

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing MySpaceCubit...');
    socketHelper.offAllForListener(_listenerId);
    log('✅ [$_listenerId] MySpaceCubit closed and cleaned up');
    return super.close();
  }
}
