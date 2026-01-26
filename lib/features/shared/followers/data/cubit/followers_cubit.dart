// features/shared/followers/views/cubit/followers_cubit.dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/shared/followers/data/models/follower_model.dart';
import 'package:tayseer/features/shared/followers/data/repositories/followers_repository.dart';
import 'package:tayseer/my_import.dart';
import 'followers_state.dart';

class FollowersCubit extends Cubit<FollowersState> {
  final FollowersRepository _repository;
  final String userId;
  final bool isFollowingView;
  final int _pageSize = 10;

  // Search related
  Timer? _searchDebounce;

  FollowersCubit({
    required FollowersRepository repository,
    required this.userId,
    this.isFollowingView = false,
  }) : _repository = repository,
       super(const FollowersState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchFollowers(isInitial: true);
  }

  Future<void> fetchFollowers({
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
        (newFollowers) {
          final updatedList = [...state.followers, ...newFollowers];
          emit(
            state.copyWith(
              followers: updatedList,
              currentPage: nextPage,
              hasMore: newFollowers.length >= _pageSize,
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
          isLoading: isSearch ? false : true, // لا نعرض loading عند البحث
          isSearching: isSearch, // تحديث حالة البحث
          followers: [],
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
        (followersList) {
          emit(
            state.copyWith(
              isLoading: false,
              isSearching: false,
              isRefreshing: false,
              followers: followersList,
              currentPage: 1,
              hasMore: followersList.length >= _pageSize,
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
    if (isFollowingView) {
      return await _repository.getFollowing(
        userId: userId,
        page: page,
        limit: _pageSize,
        searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
      );
    } else {
      return await _repository.getFollowers(
        userId: userId,
        page: page,
        limit: _pageSize,
        searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
      );
    }
  }

  void searchFollowers(String query) {
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
      fetchFollowers();
      return;
    }

    // تفعيل debounce للبحث
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      fetchFollowers(isSearch: true);
    });
  }

  Future<void> refresh() async {
    await fetchFollowers();
  }

  // دالة لمسح البحث
  void clearSearch() {
    // إلغاء البحث مباشرة بدون الـ TextController
    emit(state.copyWith(searchQuery: '', isSearching: false));
    fetchFollowers();
  }

  Future<void> toggleFollow(String targetUserId, int index) async {
    if (state.followers.isEmpty || index >= state.followers.length) return;

    final follower = state.followers[index];
    final currentFollowState = follower.isFollowing;

    // Update UI optimistically
    final updatedFollower = follower.copyWith(isFollowing: !currentFollowState);
    final updatedFollowers = List<FollowerModel>.from(state.followers);
    updatedFollowers[index] = updatedFollower;

    emit(state.copyWith(followers: updatedFollowers));

    // Call API
    final result = await _repository.toggleFollow(targetUserId);

    if (isClosed) return;

    result.fold(
      (failure) {
        // Revert on failure
        final revertedFollower = follower.copyWith(
          isFollowing: currentFollowState,
        );
        updatedFollowers[index] = revertedFollower;
        emit(
          state.copyWith(
            followers: updatedFollowers,
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
