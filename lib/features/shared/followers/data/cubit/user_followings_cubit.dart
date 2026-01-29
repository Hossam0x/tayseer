import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/features/shared/followers/data/repositories/user_followings_repository.dart';
import 'package:tayseer/my_import.dart';
import 'user_followings_state.dart';

class UserFollowingsCubit extends Cubit<UserFollowingsState> {
  final UserFollowingsRepository _repository;
  final String userId;
  final int _pageSize = 10;

  // Search related
  Timer? _searchDebounce;

  UserFollowingsCubit({
    required UserFollowingsRepository repository,
    required this.userId,
  }) : _repository = repository,
       super(const UserFollowingsState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchFollowings(isInitial: true);
  }

  Future<void> fetchFollowings({
    bool isInitial = false,
    bool loadMore = false,
    bool isSearch = false,
  }) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      if (isClosed) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _fetchData(
        page: nextPage,
        searchQuery: state.searchQuery,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (newFollowings) {
          final updatedList = [...state.followings, ...newFollowings];
          emit(
            state.copyWith(
              followings: updatedList,
              currentPage: nextPage,
              hasMore: newFollowings.length >= _pageSize,
              isLoadingMore: false,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      // إذا كان بحث جديد وليس التحميل الأول
      if (state.isSearching && !isInitial && !isSearch) return;
      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: isSearch ? false : true,
          isSearching: isSearch,
          followings: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
          isRefreshing: !isInitial && !isSearch,
        ),
      );

      final result = await _fetchData(
        page: 1,
        searchQuery: isSearch ? state.searchQuery : '',
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoading: false,
              isSearching: false,
              isRefreshing: false,
              errorMessage: failure.message,
            ),
          );
        },
        (followingsList) {
          emit(
            state.copyWith(
              isLoading: false,
              isSearching: false,
              isRefreshing: false,
              followings: followingsList,
              currentPage: 1,
              hasMore: followingsList.length >= _pageSize,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  Future<Either<Failure, List<FollowerModel>>> _fetchData({
    required int page,
    String searchQuery = '',
  }) async {
    return await _repository.getUserFollowings(
      userId: userId,
      page: page,
      limit: _pageSize,
      searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
    );
  }

  void searchFollowings(String query) {
    final trimmedQuery = query.trim();

    // إذا كان نفس الاستعلام، لا تفعل شيء
    if (trimmedQuery == state.searchQuery) return;

    // تحديث حالة البحث
    emit(
      state.copyWith(
        searchQuery: trimmedQuery,
        isSearching: trimmedQuery.isNotEmpty,
      ),
    );

    // إلغاء الـ debounce السابق إذا كان موجوداً
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    // إذا كان الاستعلام فارغاً، إعادة تحميل القائمة الأصلية
    if (trimmedQuery.isEmpty) {
      fetchFollowings();
      return;
    }

    // تفعيل debounce للبحث
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchFollowings(isSearch: true);
    });
  }

  Future<void> refresh() async {
    await fetchFollowings();
  }

  // دالة لمسح البحث
  void clearSearch() {
    // إلغاء البحث مباشرة بدون الـ TextController
    emit(state.copyWith(searchQuery: '', isSearching: false));
    fetchFollowings();
  }

  Future<void> toggleFollow(String targetUserId, int index) async {
    if (state.followings.isEmpty || index >= state.followings.length) return;

    final following = state.followings[index];
    final currentFollowState = following.isFollowing;

    // Update UI optimistically
    final updatedFollowing = following.copyWith(
      isFollowing: !currentFollowState,
    );
    final updatedFollowings = List<FollowerModel>.from(state.followings);
    updatedFollowings[index] = updatedFollowing;

    emit(state.copyWith(followings: updatedFollowings));

    // Call API
    final result = await _repository.toggleFollow(targetUserId);

    if (isClosed) return;

    result.fold(
      (failure) {
        // Revert on failure
        final revertedFollowing = following.copyWith(
          isFollowing: currentFollowState,
        );
        updatedFollowings[index] = revertedFollowing;
        emit(
          state.copyWith(
            followings: updatedFollowings,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        // Success - keep optimistic update
      },
    );
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
