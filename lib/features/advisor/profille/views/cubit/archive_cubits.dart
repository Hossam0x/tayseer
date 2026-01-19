import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/my_import.dart';
import 'archive_states.dart';

// ============================================
// 📌 ARCHIVED CHATS CUBIT
// ============================================
class ArchivedChatsCubit extends Cubit<ArchivedChatsState> {
  final ArchiveRepository _archiveRepository;
  final int _pageSize = 20;

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
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (response) {
          final updatedChats = [...state.chatRooms, ...response.chatRooms];
          emit(
            state.copyWith(
              chatRooms: updatedChats,
              currentPage: nextPage,
              hasMore: response.hasMore,
              isLoadingMore: false,
              state: CubitStates.success,
              errorMessage: null,
            ),
          );
        },
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
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (response) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              chatRooms: response.chatRooms,
              currentPage: 1,
              hasMore: response.hasMore,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<void> unarchiveChat(String chatId) async {
    final result = await _archiveRepository.unarchiveChat(chatId);

    result.fold(
      (failure) {
        emit(state.copyWith(errorMessage: failure.message));
      },
      (_) {
        // إزالة المحادثة من القائمة
        final updatedChats = state.chatRooms
            .where((chat) => chat.id != chatId)
            .toList();
        emit(state.copyWith(chatRooms: updatedChats));
      },
    );
  }

  Future<void> refresh() async {
    await fetchArchivedChats();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}

// ============================================
// 📌 ARCHIVED POSTS CUBIT
// ============================================
class ArchivedPostsCubit extends Cubit<ArchivedPostsState> {
  final ArchiveRepository _archiveRepository;
  final int _pageSize = 20;

  ArchivedPostsCubit(this._archiveRepository)
    : super(const ArchivedPostsState()) {
    fetchArchivedPosts();
  }

  Future<void> fetchArchivedPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _archiveRepository.getArchivedPosts(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (posts) {
          final updatedPosts = [...state.posts, ...posts];
          emit(
            state.copyWith(
              posts: updatedPosts,
              currentPage: nextPage,
              hasMore: posts.length == _pageSize,
              isLoadingMore: false,
              state: CubitStates.success,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _archiveRepository.getArchivedPosts(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (posts) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              posts: posts,
              currentPage: 1,
              hasMore: posts.length == _pageSize,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<void> refresh() async {
    await fetchArchivedPosts();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}

// ============================================
// 📌 ARCHIVED STORIES CUBIT
// ============================================
class ArchivedStoriesCubit extends Cubit<ArchivedStoriesState> {
  final ArchiveRepository _archiveRepository;
  final int _pageSize = 20;

  ArchivedStoriesCubit(this._archiveRepository)
    : super(const ArchivedStoriesState()) {
    fetchArchivedStories();
  }

  // archive_cubits.dart
  Future<void> fetchArchivedStories({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _archiveRepository.getArchivedStories(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (stories) {
          final updatedStories = [...state.stories, ...stories];
          emit(
            state.copyWith(
              stories: updatedStories,
              currentPage: nextPage,
              hasMore: stories.length == _pageSize,
              isLoadingMore: false,
              state: CubitStates.success,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          stories: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _archiveRepository.getArchivedStories(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              state: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (stories) {
          emit(
            state.copyWith(
              state: CubitStates.success,
              stories: stories,
              currentPage: 1,
              hasMore: stories.length == _pageSize,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<void> refresh() async {
    await fetchArchivedStories();
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
