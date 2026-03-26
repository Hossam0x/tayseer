import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepoSimple _repo;
  final tayseerSocketHelper _socketHelper = getIt<tayseerSocketHelper>();

  ChatListCubit(this._repo) : super(const ChatListState.initial());

  Future<void> loadChatRooms() async {
    emit(const ChatListState.loading());
    final result = await _repo.getAllChatRooms();
    result.fold(
      (error) => emit(ChatListState.failure(error)),
      (response) {
        emit(ChatListState.loaded(chatRooms: response.rooms));
        setupSocketListeners();
      },
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
  }

  void _handleIncomingMessage(dynamic data) {
    if (data is! Map) return;
    final chatRoomData = data['chatRoom'];
    if (chatRoomData == null) return;

    final updatedRoom = ChatRoom.fromJson(chatRoomData);

    state.maybeWhen(
      loaded: (chatRooms) {
        final rooms = List<ChatRoom>.from(chatRooms);
        final index = rooms.indexWhere((r) => r.id == updatedRoom.id);

        if (index != -1) {
          rooms.removeAt(index);
        }
        rooms.insert(0, updatedRoom);

        emit(ChatListState.loaded(chatRooms: rooms));
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

  Future<void> deleteChatRoom(String chatRoomId) async {
    final currentRooms = state.maybeMap(
      loaded: (state) => state.chatRooms,
      orElse: () => null,
    );

    // If not loaded or empty, do nothing for now
    if (currentRooms == null) return;

    // Optimistic update
    final updatedRooms = currentRooms
        .where((room) => room.id != chatRoomId)
        .toList();
    emit(ChatListState.loaded(chatRooms: updatedRooms));

    final result = await _repo.deleteChatRoom(chatRoomId);
    result.fold(
      (error) {
        // Revert on failure
        emit(ChatListState.loaded(chatRooms: currentRooms));
        emit(ChatListState.failure(error));
      },
      (success) {
        // Already updated optimally
      },
    );
  }

  Future<void> archiveChatRoom(String chatRoomId) async {
    final currentRooms = state.maybeMap(
      loaded: (state) => state.chatRooms,
      orElse: () => null,
    );
    if (currentRooms == null) return;

    // Optimistic update
    final updatedRooms = currentRooms
        .where((room) => room.id != chatRoomId)
        .toList();
    emit(ChatListState.loaded(chatRooms: updatedRooms));

    final result = await _repo.archiveChatRoom(chatRoomId);
    result.fold((error) {
      emit(ChatListState.loaded(chatRooms: currentRooms));
    }, (success) {});
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
    final currentRooms = state.maybeMap(
      loaded: (state) => state.chatRooms,
      orElse: () => null,
    );
    if (currentRooms == null) return;

    final updatedRooms = currentRooms.map((room) {
      if (room.id == chatRoomId) {
        return room.copyWith(isBlocked: isBlocked);
      }
      return room;
    }).toList();

    emit(ChatListState.loaded(chatRooms: updatedRooms));
  }

  void setActiveChatRoom(String? chatRoomId) {}
  void markMessageRed(String chatRoomId) {
    final currentRooms = state.maybeMap(
      loaded: (state) => state.chatRooms,
      orElse: () => null,
    );

    if (currentRooms == null) return;

    final updatedRooms = currentRooms.map((room) {
      if (room.id == chatRoomId) {
        return room.copyWith(unreadCount: 0);
      }
      return room;
    }).toList();

    emit(ChatListState.loaded(chatRooms: updatedRooms));
  }

  void markChatAsRead(String chatRoomId) {}
  void updateBlockStatus(String chatRoomId, bool isBlocked) =>
      _updateBlockStatus(chatRoomId, isBlocked);

  @override
  Future<void> close() {
    _socketHelper.offAllForListener('ChatListCubit_Listener');
    return super.close();
  }
}
