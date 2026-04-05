import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/user/my_space/data/model/advisor_chat_model.dart';
import 'package:tayseer/features/advisor/chat/data/event_bus/chat_event_bus.dart';
import 'dart:async';
import 'package:tayseer/my_import.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepoSimple _repo;
  final ChatCacheService _cacheService = getIt<ChatCacheService>();
  final tayseerSocketHelper _socketHelper = getIt<tayseerSocketHelper>();
  StreamSubscription<ChatUnarchiveEvent>? _unarchiveSubscription;
  StreamSubscription<ChatArchiveEvent>? _archiveSubscription;
  StreamSubscription<ChatDeleteEvent>? _deleteSubscription;

  ChatListCubit(this._repo) : super(const ChatListState.initial()) {
    // Listen to unarchive events
    _unarchiveSubscription = ChatEventBus.instance.onChatUnarchived.listen((event) {
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

  Future<void> loadChatRooms() async {
    final userId = kCurrentUserData?.id;
    if (userId == null) {
      emit(const ChatListState.failure('User not logged in'));
      return;
    }

    // 1. عرض الكاش فوراً لو موجود
    final cachedRooms = _cacheService.getCachedChatRooms(userId: userId);
    if (cachedRooms != null && cachedRooms.isNotEmpty) {
      // تحويل من AdvisorChatRoomModel لـ ChatRoom
      final chatRooms = cachedRooms.map((room) => _convertToChatRoom(room)).toList();
      emit(ChatListState.loaded(chatRooms: chatRooms, pendingRequestsCount: 0));
    } else {
      emit(const ChatListState.loading());
    }

    // 2. جلب من السيرفر وتحديث
    final result = await _repo.getAllChatRooms();
    result.fold(
      (error) {
        // لو فشل وما عندناش كاش، نعرض error
        if (cachedRooms == null || cachedRooms.isNotEmpty) {
          emit(ChatListState.failure(error));
        }
      },
      (response) async {
        emit(ChatListState.loaded(
          chatRooms: response.rooms,
          pendingRequestsCount: response.pendingRequestsCount,
        ));
        setupSocketListeners();

        // 3. حفظ في الكاش
        final roomsToCache = response.rooms.map((room) => _convertToAdvisorChatRoom(room)).toList();
        await _cacheService.saveChatRooms(userId: userId, chatRooms: roomsToCache);
      },
    );
  }

  // تحويل من AdvisorChatRoomModel لـ ChatRoom
  ChatRoom _convertToChatRoom(AdvisorChatRoomModel model) {
    return ChatRoom(
      id: model.id,
      lastMessage: model.lastMessage != null
          ? LastMessage(
              content: model.lastMessage!.content,
              sentAt: model.lastMessage!.createdAt,
            )
          : null,
      unreadCount: model.unreadCount,
      isBlocked: model.isBlocked,
      participants: model.users.map((u) => ChatUser(
        id: u.id,
        name: u.name,
        image: u.image,
        userType: u.userType,
      )).toList(),
      createdAt: model.createdAt,
      isSystemChat: model.isSystemChat,
      systemChatImage: model.systemChatImage,
    );
  }

  // تحويل من ChatRoom لـ AdvisorChatRoomModel
  AdvisorChatRoomModel _convertToAdvisorChatRoom(ChatRoom room) {
    return AdvisorChatRoomModel(
      id: room.id,
      isBlocked: room.isBlocked,
      isHaveSession: false,
      users: room.participants.map((p) => ChatUserModel(
        id: p.id,
        name: p.name,
        image: p.image,
        userType: p.userType ?? '',
      )).toList(),
      lastMessage: room.lastMessage != null
          ? LastMessageModel(
              id: '',
              sender: '',
              senderType: '',
              content: room.lastMessage!.content,
              messageType: 'text',
              chatRoom: room.id,
              createdAt: room.lastMessage!.sentAt ?? DateTime.now(),
              updatedAt: room.lastMessage!.sentAt ?? DateTime.now(),
              senderName: '',
              timeAgo: '',
            )
          : null,
      status: '',
      sender: room.participants.isNotEmpty
          ? ChatUserModel(
              id: room.participants.first.id,
              name: room.participants.first.name,
              image: room.participants.first.image,
              userType: room.participants.first.userType ?? '',
            )
          : ChatUserModel(id: '', name: '', userType: ''),
      createdAt: room.createdAt ?? DateTime.now(),
      updatedAt: room.createdAt ?? DateTime.now(),
      unreadCount: room.unreadCount,
      isSystemChat: room.isSystemChat,
      systemChatImage: room.systemChatImage,
    );
  }

  void setupSocketListeners() {
    _socketHelper.listenWithId('newMessage', 'ChatListCubit_Listener', (data) {
      _handleIncomingMessage(data);
    });

    _socketHelper.listenWithId('messageDeleted', 'ChatListCubit_Listener', (data) {
      // Reload is safest for list summary when a message is deleted
      loadChatRooms();
    });

    _socketHelper.listenWithId('blockerStatus', 'ChatListCubit_Listener', (data) {
      _handleBlockUpdate(data);
    });

    _socketHelper.listenWithId('blockedStatus', 'ChatListCubit_Listener', (data) {
      _handleBlockUpdate(data);
    });

    // Listen to message status updates
    _socketHelper.listenWithId('newMessageState', 'ChatListCubit_Listener', (data) {
      _handleMessageStateUpdate(data);
    });
  }

  void _handleChatUnarchived(String chatRoomId) {
    // Reload chat rooms to get the unarchived chat
    loadChatRooms();
  }

  void _handleChatArchived(String chatRoomId) {
    // Remove the archived chat from the list
    final currentState = state.maybeMap(
      loaded: (state) => state,
      orElse: () => null,
    );

    if (currentState == null) return;

    final updatedRooms = currentState.chatRooms
        .where((room) => room.id != chatRoomId)
        .toList();

    emit(ChatListState.loaded(
      chatRooms: updatedRooms,
      pendingRequestsCount: currentState.pendingRequestsCount,
    ));
  }

  void _handleChatDeleted(String chatRoomId) {
    // Remove the deleted chat from the list
    final currentState = state.maybeMap(
      loaded: (state) => state,
      orElse: () => null,
    );

    if (currentState == null) return;

    final updatedRooms = currentState.chatRooms
        .where((room) => room.id != chatRoomId)
        .toList();

    emit(ChatListState.loaded(
      chatRooms: updatedRooms,
      pendingRequestsCount: currentState.pendingRequestsCount,
    ));
  }

  void _handleIncomingMessage(dynamic data) {
    if (data is! Map) return;
    final chatRoomData = data['chatRoom'];
    if (chatRoomData == null) return;

    final updatedRoom = ChatRoom.fromJson(chatRoomData);

    state.maybeWhen(
      loaded: (chatRooms, pendingRequestsCount) {
        final rooms = List<ChatRoom>.from(chatRooms);
        final index = rooms.indexWhere((r) => r.id == updatedRoom.id);

        if (index != -1) {
          rooms.removeAt(index);
        }
        rooms.insert(0, updatedRoom);

        emit(ChatListState.loaded(
          chatRooms: rooms,
          pendingRequestsCount: pendingRequestsCount,
        ));
      },
      orElse: () {},
    );
  }

  void _handleBlockUpdate(dynamic data) {
    if (data is! Map) return;
    final chatRoomId = data['chatRoomId']?.toString();
    final isBlocked = data['blockExists'] ?? data['isBlocked'] ?? false;
    if (chatRoomId != null) {
      _updateBlockStatus(chatRoomId, isBlocked);
    }
  }

  void _handleMessageStateUpdate(dynamic data) {
    if (data is! Map) return;
    
    // Note: ChatRoom.lastMessage doesn't have an ID field to match against messageIds
    // This is a limitation of the current model structure
    // Status updates for advisor chat list are not implemented yet
    // TODO: Add ID field to LastMessage model in ChatRoom to enable status updates
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    final currentState = state.maybeMap(
      loaded: (state) => state,
      orElse: () => null,
    );

    // If not loaded or empty, do nothing for now
    if (currentState == null) return;

    // Optimistic update
    final updatedRooms = currentState.chatRooms
        .where((room) => room.id != chatRoomId)
        .toList();
    emit(ChatListState.loaded(
      chatRooms: updatedRooms,
      pendingRequestsCount: currentState.pendingRequestsCount,
    ));

    final result = await _repo.deleteChatRoom(chatRoomId);
    result.fold(
      (error) {
        // Revert on failure
        emit(ChatListState.loaded(
          chatRooms: currentState.chatRooms,
          pendingRequestsCount: currentState.pendingRequestsCount,
        ));
        emit(ChatListState.failure(error));
      },
      (success) {
        // Notify other parts of the app
        ChatEventBus.instance.notifyChatDeleted(chatRoomId);
      },
    );
  }

  Future<void> archiveChatRoom(String chatRoomId) async {
    final currentState = state.maybeMap(
      loaded: (state) => state,
      orElse: () => null,
    );
    if (currentState == null) return;

    // Optimistic update
    final updatedRooms = currentState.chatRooms
        .where((room) => room.id != chatRoomId)
        .toList();
    emit(ChatListState.loaded(
      chatRooms: updatedRooms,
      pendingRequestsCount: currentState.pendingRequestsCount,
    ));

    final result = await _repo.archiveChatRoom(chatRoomId);
    result.fold((error) {
      emit(ChatListState.loaded(
        chatRooms: currentState.chatRooms,
        pendingRequestsCount: currentState.pendingRequestsCount,
      ));
    }, (success) {
      // Notify other parts of the app
      ChatEventBus.instance.notifyChatArchived(chatRoomId);
    });
  }

  Future<void> blockUser({
    required String blockedId,
    required String chatRoomId,
  }) async {
    final result = await _repo.blockUser(blockedId: blockedId);
    result.fold(
      (error) => null,
      (message) => _updateBlockStatus(chatRoomId, true),
    );
  }

  Future<void> unblockUser({
    required String blockedId,
    required String chatRoomId,
  }) async {
    final result = await _repo.unblockUser(blockedId: blockedId);
    result.fold(
      (error) => null, // Handle error
      (message) => _updateBlockStatus(chatRoomId, false),
    );
  }

  void _updateBlockStatus(String chatRoomId, bool isBlocked) {
    final currentState = state.maybeMap(
      loaded: (state) => state,
      orElse: () => null,
    );
    if (currentState == null) return;

    final updatedRooms = currentState.chatRooms.map((room) {
      if (room.id == chatRoomId) {
        return room.copyWith(isBlocked: isBlocked);
      }
      return room;
    }).toList();

    emit(ChatListState.loaded(
      chatRooms: updatedRooms,
      pendingRequestsCount: currentState.pendingRequestsCount,
    ));
  }

  void setActiveChatRoom(String? chatRoomId) {}
  void markMessageRed(String chatRoomId) {
    final currentState = state.maybeMap(
      loaded: (state) => state,
      orElse: () => null,
    );

    if (currentState == null) return;

    final updatedRooms = currentState.chatRooms.map((room) {
      if (room.id == chatRoomId) {
        return room.copyWith(unreadCount: 0);
      }
      return room;
    }).toList();

    emit(ChatListState.loaded(
      chatRooms: updatedRooms,
      pendingRequestsCount: currentState.pendingRequestsCount,
    ));
  }

  void markChatAsRead(String chatRoomId) {}
  void updateBlockStatus(String chatRoomId, bool isBlocked) =>
      _updateBlockStatus(chatRoomId, isBlocked);

  @override
  Future<void> close() {
    _socketHelper.offAllForListener('ChatListCubit_Listener');
    _unarchiveSubscription?.cancel();
    _archiveSubscription?.cancel();
    _deleteSubscription?.cancel();
    return super.close();
  }
}
