import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/my_import.dart';
import 'ratings_state.dart';

class RatingsCubit extends Cubit<RatingsState> {
  final RatingsRepository _ratingsRepository;
  final int _pageSize = 10;

  RatingsCubit(this._ratingsRepository) : super(const RatingsState()) {
    fetchRatings();
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH RATINGS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchRatings({bool loadMore = false}) async {
    if (loadMore) {
      // لا تسمح بتحميل المزيد إذا كان التحميل جارياً أو لا يوجد المزيد
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _ratingsRepository.getAdvisorRatings(
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
          final updatedRatings = [...state.ratings, ...response.ratings];
          emit(
            state.copyWith(
              summary: response.summary,
              ratings: updatedRatings,
              currentPage: nextPage,
              hasMore: response.hasMore,
              isLoadingMore: false,
              errorMessage: null,
            ),
          );
        },
      );
    } else {
      // التحميل الأولي
      emit(
        state.copyWith(
          state: CubitStates.loading,
          ratings: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _ratingsRepository.getAdvisorRatings(
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
              summary: response.summary,
              ratings: response.ratings,
              currentPage: 1,
              hasMore: response.hasMore,
              errorMessage: null,
            ),
          );
        },
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH RATINGS
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh() async {
    await fetchRatings(loadMore: false);
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 CLEAR ERROR
  // ═══════════════════════════════════════════════════════════
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
