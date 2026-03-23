import 'package:tayseer/features/advisor/profille/data/models/archive_models.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archived_chats_state.dart';
import 'package:tayseer/my_import.dart';

class ArchivedChatsCubit extends Cubit<ArchivedChatsState> {
  final ArchiveRepository _archiveRepository;
  final int _pageSize = 10;

  ArchivedChatsCubit(this._archiveRepository)
    : super(const ArchivedChatsState()) {
    fetchArchivedChats();
  }

  Future<void> fetchArchivedChats({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _archiveRepository.getArchivedChats(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(isLoadingMore: false, errorMessage: failure.message),
        ),
        (response) => emit(
          state.copyWith(
            chatRooms: [...state.chatRooms, ...response.chatRooms],
            currentPage: nextPage,
            hasMore: response.hasMore,
            isLoadingMore: false,
            state: CubitStates.success,
            errorMessage: null,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          chatRooms: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _archiveRepository.getArchivedChats(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) => emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        ),
        (response) => emit(
          state.copyWith(
            state: CubitStates.success,
            chatRooms: response.chatRooms,
            currentPage: 1,
            hasMore: response.hasMore,
            errorMessage: null,
          ),
        ),
      );
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    final originalChats = List<ArchiveChatRoomModel>.from(state.chatRooms);
    emit(
      state.copyWith(
        chatRooms: state.chatRooms.where((c) => c.id != chatId).toList(),
        unarchiveActionState: CubitStates.loading,
      ),
    );

    final result = await _archiveRepository.unarchiveChat(chatId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          chatRooms: originalChats,
          unarchiveActionState: CubitStates.failure,
          unarchiveMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          unarchiveActionState: CubitStates.success,
          unarchiveMessage: 'chat_unarchived_success',
        ),
      ),
    );
  }

  Future<void> deleteChatRoom(String chatId) async {
    final originalChats = List<ArchiveChatRoomModel>.from(state.chatRooms);
    emit(
      state.copyWith(
        chatRooms: state.chatRooms.where((c) => c.id != chatId).toList(),
      ),
    );

    final result = await _archiveRepository.deleteChatRoom(chatId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          chatRooms: originalChats,
          errorMessage: failure.message,
          state: CubitStates.failure,
        ),
      ),
      (_) => emit(state.copyWith(errorMessage: null)),
    );
  }

  Future<void> blockUser({
    required String userId,
    required String chatId,
  }) async {
    final result = await _archiveRepository.blockUser(userId: userId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
          state: CubitStates.failure,
        ),
      ),
      (_) => _updateChatBlockStatus(chatId, true),
    );
  }

  Future<void> unblockUser({
    required String userId,
    required String chatId,
  }) async {
    final result = await _archiveRepository.unblockUser(userId: userId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.message,
          state: CubitStates.failure,
        ),
      ),
      (_) => _updateChatBlockStatus(chatId, false),
    );
  }

  void _updateChatBlockStatus(String chatId, bool isBlocked) {
    emit(
      state.copyWith(
        chatRooms: state.chatRooms.map((chat) {
          return chat.id == chatId ? chat.copyWith(isBlocked: isBlocked) : chat;
        }).toList(),
      ),
    );
  }

  void resetUnarchiveState() {
    emit(
      state.copyWith(
        unarchiveActionState: CubitStates.initial,
        unarchiveMessage: null,
      ),
    );
  }

  Future<void> refresh() => fetchArchivedChats();

  void clearError() => emit(state.copyWith(errorMessage: null));
}
