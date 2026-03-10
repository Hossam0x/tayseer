import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/profille/data/models/rating_model.dart';
import 'package:tayseer/features/advisor/profille/data/repositories/ratings_repository.dart';
import 'package:tayseer/my_import.dart';
import 'ratings_state.dart';

class RatingsCubit extends Cubit<RatingsState> {
  final RatingsRepository _ratingsRepository;
  final int _pageSize = 10;
  // String? _currentAdvisorId;

  RatingsCubit(this._ratingsRepository) : super(const RatingsState());

  // ═══════════════════════════════════════════════════════════
  // 📌 FETCH RATINGS
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchRatings({
    required String advisorId,
    bool loadMore = false,
    bool isSilent = false, // ⭐ Silent Refresh (مثل Posts)
    bool forceRefresh = false, // ⭐ إعادة تحميل إجباري
  }) async {
    // _currentAdvisorId = advisorId;

    // ═══ Load More ═══
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _ratingsRepository.getAdvisorRatings(
        advisorId: advisorId,
        page: nextPage,
        limit: _pageSize,
      );

      if (isClosed) return;

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
              state: CubitStates.success,
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
      return;
    }

    // ═══ Force Refresh أو أول تحميل ═══
    if (forceRefresh || state.ratings.isEmpty) {
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
        advisorId: advisorId,
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
              hasLoadedOnce: true, // ⭐ تم التحميل
            ),
          );
        },
      );
      return;
    }

    // ═══ Silent Refresh (من غير loading) ═══
    if (isSilent && state.ratings.isNotEmpty) {
      final result = await _ratingsRepository.getAdvisorRatings(
        advisorId: advisorId,
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) {
          // Silent failure - لا نعرض خطأ
        },
        (response) {
          // تحديث فقط إذا كانت البيانات مختلفة
          if (!_listsAreEqual(state.ratings, response.ratings)) {
            emit(
              state.copyWith(
                summary: response.summary,
                ratings: response.ratings,
                currentPage: 1,
                hasMore: response.hasMore,
                errorMessage: null,
              ),
            );
          }
        },
      );
    }
  }

  // ⭐ مساعدة للمقارنة (منع flicker)
  bool _listsAreEqual(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 REFRESH RATINGS
  // ═══════════════════════════════════════════════════════════
  Future<void> refresh({String? advisorId}) async {
    if (advisorId != null) {
      await fetchRatings(
        advisorId: advisorId,
        loadMore: false,
        isSilent: false, // Normal refresh
        forceRefresh: true, // ⭐ Force reload to update list
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 SUBMIT RATING
  // ═══════════════════════════════════════════════════════════
  Future<void> submitRating({
    required String advisorId,
    required int rating,
    required String review,
    required VoidCallback onSuccess,
    required Function(String) onFailure,
  }) async {
    final result = await _ratingsRepository.submitRating(
      advisorId: advisorId,
      rating: rating,
      review: review,
    );

    result.fold(
      (failure) => onFailure(failure.message),
      (newRating) {
        final existingIndex = state.ratings.indexWhere(
          (r) => r.id == newRating.id,
        );
        List<RatingModel> updatedRatings;
        RatingSummaryModel? updatedSummary;

        if (existingIndex != -1) {
          // ⭐ حالة التعديل (Edit Rating) - استبدال القديم بالجديد
          final oldRating = state.ratings[existingIndex];
          updatedRatings = List<RatingModel>.from(state.ratings);
          updatedRatings[existingIndex] = newRating;

          // تحديث الـ Summary لعملية التعديل
          if (state.summary != null) {
            final oldSummary = state.summary!;
            final oldValue = oldRating.rating;
            final newValue = newRating.rating;

            // حساب المتوسط الجديد: طرح التقييم القديم وإضافة الجديد (العدد الكلي ثابت)
            final double newAverage =
                oldSummary.totalRatings > 0
                    ? ((oldSummary.averageRating * oldSummary.totalRatings) -
                            oldValue +
                            newValue) /
                        oldSummary.totalRatings
                    : newValue;

            final newBreakdown = Map<int, int>.from(oldSummary.starsBreakdown);
            // تحديث توزيع النجوم
            final oldKey = oldValue.toInt();
            final newKey = newValue.toInt();

            if (newBreakdown.containsKey(oldKey)) {
              newBreakdown[oldKey] = (newBreakdown[oldKey] ?? 1) - 1;
              if (newBreakdown[oldKey]! < 0) newBreakdown[oldKey] = 0;
            }
            newBreakdown[newKey] = (newBreakdown[newKey] ?? 0) + 1;

            updatedSummary = RatingSummaryModel(
              averageRating: newAverage,
              totalRatings: oldSummary.totalRatings,
              starsBreakdown: newBreakdown,
            );
          }
        } else {
          // ⭐ حالة إضافة تقييم جديد (New Rating) - الإضافة في البداية
          updatedRatings = [newRating, ...state.ratings];

          // تحديث الـ Summary لعملية الإضافة
          if (state.summary != null) {
            final oldSummary = state.summary!;
            final newTotal = oldSummary.totalRatings + 1;
            final newAverage =
                ((oldSummary.averageRating * oldSummary.totalRatings) +
                        newRating.rating) /
                    newTotal;

            final newBreakdown = Map<int, int>.from(oldSummary.starsBreakdown);
            final newKey = newRating.rating.toInt();
            newBreakdown[newKey] = (newBreakdown[newKey] ?? 0) + 1;

            updatedSummary = RatingSummaryModel(
              averageRating: newAverage,
              totalRatings: newTotal,
              starsBreakdown: newBreakdown,
            );
          }
        }

        emit(
          state.copyWith(
            ratings: updatedRatings,
            summary: updatedSummary ?? state.summary,
          ),
        );

        onSuccess();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 FORMAT DATE
  // ═══════════════════════════════════════════════════════════
  String formatDate(String dateString, String lang) {
    try {
      final parsedDate = DateFormat('M/d/yyyy, hh:mm:ss a', 'en').parse(
        dateString,
      );
      return DateFormat('dd MMMM yyyy', lang).format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  // ═══════════════════════════════════════════════════════════
  // 📌 CLEAR ERROR
  // ═══════════════════════════════════════════════════════════
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
