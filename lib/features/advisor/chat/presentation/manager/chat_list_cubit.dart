import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';
import 'package:tayseer/features/advisor/chat/presentation/manager/chat_list_state.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final ChatRepoSimple _repo;

  ChatListCubit(this._repo) : super(const ChatListState.initial());

  Future<void> loadChatRooms() async {
    emit(const ChatListState.loading());
    final result = await _repo.getAllChatRooms();
    result.fold(
      (error) => emit(ChatListState.failure(error)),
      (response) => emit(ChatListState.loaded(chatRooms: response.data.rooms)),
    );
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
}
