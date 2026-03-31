import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/chat_room_type.dart';
import 'package:tayseer/features/advisor/chat/data/event_bus/chat_event_bus.dart';
import 'package:tayseer/features/advisor/chat/data/model/chatView/chat_item_model.dart';
import 'package:tayseer/features/advisor/chat/data/repo/chat_repo_simple.dart';

part 'chat_search_state.dart';

class ChatSearchCubit extends Cubit<ChatSearchState> {
  final ChatRepoSimple _chatRepo;

  ChatSearchCubit(this._chatRepo) : super(ChatSearchInitial());

  Future<void> searchChatRooms({
    required String searchKey,
    required ChatRoomType chatRoomType,
  }) async {
    if (searchKey.trim().isEmpty) {
      emit(ChatSearchInitial());
      return;
    }

    emit(ChatSearchLoading());

    final result = await _chatRepo.searchChatRooms(
      searchKey: searchKey,
      chatRoomType: chatRoomType.value,
    );

    result.fold(
      (error) => emit(ChatSearchError(error)),
      (response) {
        if (response.rooms.isEmpty) {
          emit(ChatSearchEmpty());
        } else {
          emit(ChatSearchSuccess(response.rooms));
        }
      },
    );
  }

  Future<void> archiveChatRoom(String chatRoomId) async {
    final currentState = state;
    if (currentState is! ChatSearchSuccess) return;

    // Optimistic update - remove from list
    final updatedRooms = currentState.rooms
        .where((room) => room.id != chatRoomId)
        .toList();
    
    if (updatedRooms.isEmpty) {
      emit(ChatSearchEmpty());
    } else {
      emit(ChatSearchSuccess(updatedRooms));
    }

    final result = await _chatRepo.archiveChatRoom(chatRoomId);
    result.fold(
      (error) {
        // Revert on failure
        emit(ChatSearchSuccess(currentState.rooms));
      },
      (success) {
        // Notify other parts of the app
        ChatEventBus.instance.notifyChatArchived(chatRoomId);
      },
    );
  }

  Future<void> deleteChatRoom(String chatRoomId) async {
    final currentState = state;
    if (currentState is! ChatSearchSuccess) return;

    // Optimistic update - remove from list
    final updatedRooms = currentState.rooms
        .where((room) => room.id != chatRoomId)
        .toList();
    
    if (updatedRooms.isEmpty) {
      emit(ChatSearchEmpty());
    } else {
      emit(ChatSearchSuccess(updatedRooms));
    }

    final result = await _chatRepo.deleteChatRoom(chatRoomId);
    result.fold(
      (error) {
        // Revert on failure
        emit(ChatSearchSuccess(currentState.rooms));
        emit(ChatSearchError(error));
      },
      (success) {
        // Notify other parts of the app
        ChatEventBus.instance.notifyChatDeleted(chatRoomId);
      },
    );
  }

  void clearSearch() {
    emit(ChatSearchInitial());
  }
}
