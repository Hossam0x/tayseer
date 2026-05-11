import 'dart:async';
import 'dart:developer';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/event_bus/chat_event_bus.dart';
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

  StreamSubscription<ChatUnarchiveEvent>? _unarchiveSubscription;
  StreamSubscription<ChatArchiveEvent>? _archiveSubscription;
  StreamSubscription<ChatDeleteEvent>? _deleteSubscription;

  MySpaceCubit(this.mySpaceRepo) : super(const MySpaceState()) {
    _listenerId =
        'MySpaceCubit_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
    log('🆔 MySpaceCubit created with ID: $_listenerId');

    // Listen to chat events
    _setupEventBusListeners();
  }

  void _setupEventBusListeners() {
    // Listen to unarchive events
    _unarchiveSubscription = ChatEventBus.instance.onChatUnarchived.listen((
      event,
    ) {
      _handleChatUnarchived(event.chatRoomId);
    });

    // Listen to archive events
    _archiveSubscription = ChatEventBus.instance.onChatArchived.listen((event) {
      _handleChatArchived(event.chatRoomId);
    });

    // Listen to delete events
    _deleteSubscription = ChatEventBus.instance.onChatDeleted.listen((event) {
      _handleChatDeleted(event.chatRoomId);
    });
  }

  void _handleChatUnarchived(String chatRoomId) {
    // Reload chat rooms to get the unarchived chat
    log('📥 [$_listenerId] Chat unarchived: $chatRoomId - reloading');
    getAdvisorChat();
  }

  void _handleChatArchived(String chatRoomId) {
    // Remove the archived chat from the list
    log('📤 [$_listenerId] Chat archived: $chatRoomId - removing from list');
    final currentChatData = state.advisorChatModel?.data;
    if (currentChatData == null) return;

    final updatedRooms = currentChatData.chatRooms
        .where((room) => room.id != chatRoomId)
        .toList();

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
  }

  void _handleChatDeleted(String chatRoomId) {
    log('🗑️ [$_listenerId] Chat deleted: $chatRoomId - removing from list');
    final currentChatData = state.advisorChatModel?.data;
    if (currentChatData == null) return;

    final updatedRooms = currentChatData.chatRooms
        .where((room) => room.id != chatRoomId)
        .toList();

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

  /// ✅ تحديث آخر رسالة لغرفة معينة بدون إعادة تحميل كامل
  void updateLastMessage({
    required String chatRoomId,
    required String content,
    required DateTime sentAt,
  }) {
    _updateChatRoomLastMessage(
      chatRoomId: chatRoomId,
      messageId: '',
      content: content,
      createdAt: sentAt.toIso8601String(),
      updatedAt: sentAt.toIso8601String(),
      isMe: true,
      senderName: '',
      messageType: 'text',
    );
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

    final cachedRooms = _cacheService.getCachedUserChatRooms(userId: userId);
    if (cachedRooms != null && cachedRooms.isNotEmpty) {
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
      // ✅ لو في data موجودة في الـ state، متعملش emit(loading) عشان ما تمسحش الـ systemRooms
      if (state.advisorChatModel == null) {
        _safeEmit(state.copyWith(advisorChatState: CubitStates.loading));
      }
    }

    CubitStates.printState(
      stateName: "MySpaceCubit - getAdvisorChat",
      state: CubitStates.loading,
    );

    final result = await mySpaceRepo.getadvisorchat();

    result.fold(
      (failure) {
        CubitStates.printState(
          stateName: "MySpaceCubit - getAdvisorChat",
          state: CubitStates.failure,
        );

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

        // ✅ دايماً حط lastUpdateTime جديد عشان Equatable يشوف فرق ويعمل rebuild
        _safeEmit(
          state.copyWith(
            advisorChatState: CubitStates.success,
            advisorChatModel: advisorChatModel,
            lastUpdateTime: DateTime.now(),
          ),
        );

        await _cacheService.saveUserChatRooms(
          userId: userId,
          chatRooms: advisorChatModel.data.chatRooms,
        );
      },
    );
  }

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

    socketHelper.listenWithId('newMessageState', _listenerId, (data) {
      _handleMessageStateUpdateForChatList(data);
    });
  }

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
      final createdAt =
          messageData['sentAt']?.toString() ??
          messageData['createdAt']?.toString() ??
          '';
      final updatedAt = messageData['updatedAt']?.toString() ?? '';
      final isMe = messageData['isMe'] ?? false;
      final senderName = messageData['senderName']?.toString() ?? '';
      final messageType =
          messageData['contentType']?.toString() ??
          messageData['messageType']?.toString() ??
          'text';
      final messageId =
          messageData['id']?.toString() ?? messageData['_id']?.toString() ?? '';

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
          content: _extractContentForDisplay(content, messageType),
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
        log(
          '📝 [$_listenerId] New content: "$content", messageType: $messageType',
        );

        final updatedLastMessage = LastMessageModel(
          id: messageId.isNotEmpty ? messageId : (room.lastMessage?.id ?? ''),
          sender: room.lastMessage?.sender ?? '',
          senderType: room.lastMessage?.senderType ?? '',
          content: content,
          messageType: messageType,
          chatRoom: chatRoomId,
          createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(updatedAt) ?? DateTime.now(),
          senderName: senderName,
          timeAgo: 'الآن',
          status: 'SENT', // New messages start as SENT
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

  /// Handle message status updates for chat list
  void _handleMessageStateUpdateForChatList(dynamic data) {
    if (isClosed) {
      log(
        '⚠️ [$_listenerId] Received message state update but Cubit is closed - ignoring',
      );
      return;
    }

    log('📊 [$_listenerId] Processing message status update for chat list');

    try {
      if (data is! Map) return;

      final status = data['status']?.toString() ?? '';
      final messageIds = data['messageIds'];

      if (messageIds is! List || messageIds.isEmpty) return;

      log(
        '📊 [$_listenerId] Status: $status, Message IDs: ${messageIds.length}',
      );

      // Update status in chat list's last message if it matches
      final currentChatData = state.advisorChatModel?.data;
      if (currentChatData == null) return;

      bool hasUpdates = false;
      final updatedRooms = currentChatData.chatRooms.map((room) {
        final lastMessageId = room.lastMessage?.id;
        if (lastMessageId != null && messageIds.contains(lastMessageId)) {
          log(
            '✅ [$_listenerId] Updating status for room ${room.id} last message',
          );
          hasUpdates = true;

          final updatedLastMessage = LastMessageModel(
            id: room.lastMessage!.id,
            sender: room.lastMessage!.sender,
            senderType: room.lastMessage!.senderType,
            content: room.lastMessage!.content,
            messageType: room.lastMessage!.messageType,
            chatRoom: room.lastMessage!.chatRoom,
            createdAt: room.lastMessage!.createdAt,
            updatedAt: room.lastMessage!.updatedAt,
            senderName: room.lastMessage!.senderName,
            timeAgo: room.lastMessage!.timeAgo,
            status: status, // Update status
          );

          return AdvisorChatRoomModel(
            id: room.id,
            isBlocked: room.isBlocked,
            isHaveSession: room.isHaveSession,
            users: room.users,
            lastMessage: updatedLastMessage,
            lastMessageAt: room.lastMessageAt,
            status: room.status,
            sender: room.sender,
            createdAt: room.createdAt,
            updatedAt: room.updatedAt,
            unreadCount: room.unreadCount,
          );
        }
        return room;
      }).toList();

      if (hasUpdates) {
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

        log('✅ [$_listenerId] Chat list status updated successfully');
      }
    } catch (e, stackTrace) {
      log('❌ [$_listenerId] Error processing message state update: $e');
      log('StackTrace: $stackTrace');
    }
  }

  /// Extract content from message for display
  String _extractContentForDisplay(dynamic content, String messageType) {
    log(
      '🔍 [$_listenerId] _extractContentForDisplay - messageType: $messageType',
    );

    // معالجة أنواع الميديا
    if (messageType == 'image' || messageType == 'images/videos') {
      log('✅ [$_listenerId] Detected image/video, returning "صورة"');
      return 'صورة';
    } else if (messageType == 'video') {
      log('✅ [$_listenerId] Detected video, returning "فيديو"');
      return 'فيديو';
    } else if (messageType == 'audio' ||
        messageType == 'voice' ||
        messageType == 'record') {
      log(
        '✅ [$_listenerId] Detected audio/voice/record, returning "رسالة صوتية"',
      );
      return 'رسالة صوتية';
    }

    // للرسائل النصية والنظام
    log('📝 [$_listenerId] Text/system message, extracting content');
    return _extractContent(content);
  }

  /// Extract content from message
  String _extractContent(dynamic content) {
    if (content == null) return '';
    if (content is String) {
      // Check if it's a media URL (audio/video/image)
      final lowerContent = content.toLowerCase();
      if (lowerContent.contains('.mp3') ||
          lowerContent.contains('.wav') ||
          lowerContent.contains('.m4a') ||
          lowerContent.contains('.aac') ||
          lowerContent.contains('audio') ||
          lowerContent.contains('record')) {
        return 'رسالة صوتية';
      } else if (lowerContent.contains('.mp4') ||
          lowerContent.contains('.mov') ||
          lowerContent.contains('.avi') ||
          lowerContent.contains('video')) {
        return 'فيديو';
      } else if (lowerContent.contains('.jpg') ||
          lowerContent.contains('.jpeg') ||
          lowerContent.contains('.png') ||
          lowerContent.contains('.gif') ||
          lowerContent.contains('image')) {
        return 'صورة';
      }
      return content;
    } else if (content is List && content.isNotEmpty) {
      final first = content.first;
      if (first is Map) {
        final mediaUrl =
            first['media']?.toString() ?? first['url']?.toString() ?? '';
        if (mediaUrl.isNotEmpty) {
          // Check media type from URL
          final lowerUrl = mediaUrl.toLowerCase();
          if (lowerUrl.contains('.mp3') ||
              lowerUrl.contains('.wav') ||
              lowerUrl.contains('.m4a') ||
              lowerUrl.contains('.aac')) {
            return 'رسالة صوتية';
          } else if (lowerUrl.contains('.mp4') ||
              lowerUrl.contains('.mov') ||
              lowerUrl.contains('.avi')) {
            return 'فيديو';
          } else if (lowerUrl.contains('.jpg') ||
              lowerUrl.contains('.jpeg') ||
              lowerUrl.contains('.png') ||
              lowerUrl.contains('.gif')) {
            return 'صورة';
          }
        }
        return mediaUrl;
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
    return result.fold(
      (failure) {
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
      },
      (_) {
        // Notify other parts of the app
        ChatEventBus.instance.notifyChatDeleted(chatRoomId);
        return true;
      },
    );
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
    return result.fold(
      (failure) {
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
      },
      (_) {
        // Notify other parts of the app
        ChatEventBus.instance.notifyChatArchived(chatRoomId);
        return true;
      },
    );
  }

  /// Reset State
  void resetState() {
    _safeEmit(const MySpaceState());
  }

  /// Force rebuild للـ BlocBuilder بدون API call
  /// بيستخدم لما نرجع من chat عشان الـ system rooms تظهر تاني
  void touchState() {
    _safeEmit(state.copyWith(lastUpdateTime: DateTime.now()));
  }

  @override
  Future<void> close() {
    log('🔴 [$_listenerId] Closing MySpaceCubit...');
    socketHelper.offAllForListener(_listenerId);
    _unarchiveSubscription?.cancel();
    _archiveSubscription?.cancel();
    _deleteSubscription?.cancel();
    log('✅ [$_listenerId] MySpaceCubit closed and cleaned up');
    return super.close();
  }
}
