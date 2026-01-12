import 'package:tayseer/features/advisor/home/reposiotry/home_repository.dart';
import 'package:tayseer/features/advisor/profille/view_model/profile_state.dart';
import 'package:tayseer/my_import.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final HomeRepository homeRepository;
  final int pageSize = 10;

  ProfileCubit(this.homeRepository) : super(const ProfileState());

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH POSTS (مؤقتاً - نفس request الـ Home)
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchPosts({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await homeRepository.fetchPosts(page: nextPage);

      result.fold(
        (failure) {
          emit(
            state.copyWith(isLoadingMore: false, errorMessage: failure.message),
          );
        },
        (newPosts) {
          final updatedList = [...state.posts, ...newPosts];
          emit(
            state.copyWith(
              posts: updatedList,
              currentPage: nextPage,
              hasMore: newPosts.length >= pageSize,
              isLoadingMore: false,
            ),
          );
        },
      );
    } else {
      emit(
        state.copyWith(
          postsState: CubitStates.loading,
          posts: [],
          currentPage: 1,
          hasMore: true,
        ),
      );
      final result = await homeRepository.fetchPosts(page: 1);
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              postsState: CubitStates.failure,
              errorMessage: failure.message,
            ),
          );
        },
        (postsList) {
          emit(
            state.copyWith(
              postsState: CubitStates.success,
              posts: postsList,
              currentPage: 1,
              hasMore: postsList.length >= pageSize,
            ),
          );
        },
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH POSTS
  // ═══════════════════════════════════════════════════════════
  Future<void> refreshPosts() async {
    await fetchPosts(loadMore: false);
  }
}
