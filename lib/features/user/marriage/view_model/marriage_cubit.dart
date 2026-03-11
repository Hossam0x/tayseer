import 'dart:async';
import 'package:dartz/dartz.dart'; // ✅ أضف هذا
import 'package:flutter/animation.dart';
import 'package:tayseer/features/user/marriage/model/user_marriage_model.dart'; // ✅ أضف هذا
import 'package:tayseer/features/user/marriage/view_model/marriage_event_bus.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageCubit extends Cubit<MarriageState> {
  MarriageCubit({MarriageRepository? repository})
    : _repo = repository ?? getIt<MarriageRepository>(),
      super(const MarriageState()) {
    _filterSubscription = MarriageEventBus.instance.onFilterApplied.listen(
      (filters) => fetchMarriageProfile(filters: filters),
    );
  }

  final MarriageRepository _repo;
  late final StreamSubscription<Map<String, dynamic>> _filterSubscription;

  // ═══ Animation ═══
  AnimationController? _cardController;
  CurvedAnimation? _cardAnimation;

  void initAnimation(TickerProvider vsync) {
    if (_cardController != null) return;
    _cardController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 350),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController!,
      curve: Curves.easeOutCubic,
    );
    _cardController!.addListener(_onAnimationTick);
  }

  void _onAnimationTick() {
    final newProgress = _cardAnimation?.value ?? 0;
    if ((state.swipeProgress - newProgress).abs() > 0.005) {
      emit(state.copyWith(swipeProgress: newProgress));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // FETCH — الصفحة الأولى
  // ═══════════════════════════════════════════════════════════
  Future<void> fetchMarriageProfile({Map<String, dynamic>? filters}) async {
  emit(
    state.copyWith(
      marriageProfileState: CubitStates.loading,
      errorMessage: null,
      activeFilters: filters ?? state.activeFilters,
    ),
  );

  // ✅ اجلب المفضلين والبروفايلات بالتوازي
  final results = await Future.wait([
    _repo.getMarriageProfile("1", filters: state.activeFilters),
    _repo.getFavoriteIds(),
  ]);

  final profileResult = results[0] as Either<Failure, UsersMarriageResponse>;
  final favoritesResult = results[1] as Either<Failure, List<String>>;

  // ✅ استخرج IDs المفضلين
  final fetchedFavoriteIds = favoritesResult.fold(
    (_) => <String>{},
    (ids) => ids.toSet(),
  );

  profileResult.fold(
    (failure) => emit(
      state.copyWith(
        marriageProfileState: CubitStates.failure,
        errorMessage: failure.message,
      ),
    ),
    (profile) {
      if (isClosed) return;

      // ✅ ادمج المفضلين الجدد مع الموجودين
      final mergedFavorites = {
        ...state.favoritedIds,
        ...fetchedFavoriteIds,
      };

      emit(
        state.copyWith(
          marriageProfileState: CubitStates.success,
          profile: profile,
          currentIndex: 0,
          allUsers: profile.data?.users ?? [],
          currentPage: profile.data?.pagination?.currentPage ?? 1,
          totalPages: profile.data?.pagination?.totalPages ?? 1,
          favoritedIds: mergedFavorites, // ✅
        ),
      );
    },
  );
}
  // ═══════════════════════════════════════════════════════════
  // LOAD MORE — تحميل الصفحة التالية
  // ═══════════════════════════════════════════════════════════
  Future<void> loadMoreUsers() async {
    if (state.isLoadingMore) return;
    if (state.currentPage >= state.totalPages) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await _repo.getMarriageProfile(
      (state.currentPage + 1).toString(),
      filters: state.activeFilters,
    );

    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (profile) {
        emit(
          state.copyWith(
            isLoadingMore: false,
            allUsers: [...state.allUsers, ...profile.data?.users ?? []],
            currentPage:
                profile.data?.pagination?.currentPage ?? state.currentPage,
            totalPages:
                profile.data?.pagination?.totalPages ?? state.totalPages,
            // ✅ حافظ على favoritedIds بدون تغيير
            favoritedIds: state.favoritedIds,
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SWIPE LIKE — like فقط، بدون favorite
  // ═══════════════════════════════════════════════════════════
  Future<void> swipeLike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;

    emit(state.copyWith(swipeDirection: 1, isAnimating: true));

    userInteraction(personId: personId, interactionType: 'like');
    await _cardController!.forward(from: 0);
    _onSwipeComplete(personId: personId, hasSinglePerson: hasSinglePerson);
  }

  // ═══════════════════════════════════════════════════════════
  // SWIPE DISLIKE
  // ═══════════════════════════════════════════════════════════
  Future<void> swipeDislike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;

    emit(state.copyWith(swipeDirection: -1, isAnimating: true));
    userInteraction(personId: personId, interactionType: 'dislike');
    await _cardController!.forward(from: 0);
    _onSwipeComplete(personId: personId, hasSinglePerson: hasSinglePerson);
  }

  // ═══════════════════════════════════════════════════════════
  // ON SWIPE COMPLETE
  // ═══════════════════════════════════════════════════════════
  void _onSwipeComplete({
    required String personId,
    required bool hasSinglePerson,
  }) {
    _cardController!.value = 0;

    if (!hasSinglePerson) {
      final updatedUsers = state.allUsers
          .where((u) => u.user?.id != personId)
          .toList();
      final newLength = updatedUsers.length;

      if (newLength <= 3) {
        loadMoreUsers();
      }

      int newIndex = state.currentIndex;
      if (newIndex >= newLength) {
        newIndex = newLength > 0 ? newLength - 1 : 0;
      }

      emit(
        state.copyWith(
          allUsers: updatedUsers,
          currentIndex: newIndex,
          swipeDirection: 0,
          swipeProgress: 0,
          isAnimating: false,
          isScrollingDown: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          swipeDirection: 0,
          swipeProgress: 0,
          isAnimating: false,
          isScrollingDown: false,
        ),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HISTORY
  // ═══════════════════════════════════════════════════════════
  void showHistoryView() => emit(
    state.copyWith(showHistory: true, selectedHistoryFilter: "liked_you"),
  );
  void hideHistoryView() => emit(state.copyWith(showHistory: false));
  void setHistoryFilter(String filter) =>
      emit(state.copyWith(selectedHistoryFilter: filter));

  // ═══════════════════════════════════════════════════════════
  // SCROLL
  // ═══════════════════════════════════════════════════════════
  void setScrollingDown(bool isDown) {
    if (state.isScrollingDown == isDown) return;
    emit(state.copyWith(isScrollingDown: isDown));
  }

  // ═══════════════════════════════════════════════════════════
  // TABS
  // ═══════════════════════════════════════════════════════════
  void setMarriageTab(bool isMarriage) {
    if (state.isMarriageTab == isMarriage) return;
    if (state.showHistory) {
      emit(state.copyWith(showHistory: false, isMarriageTab: isMarriage));
    } else {
      emit(state.copyWith(isMarriageTab: isMarriage));
    }
  }

  // ═══════════════════════════════════════════════════════════
  // INTERACTIONS
  // ═══════════════════════════════════════════════════════════
  Future<void> userInteraction({
    required String personId,
    required String interactionType,
  }) async {
    emit(
      state.copyWith(
        userInteractionState: CubitStates.initial,
        errorMessage: null,
      ),
    );

    final result = await _repo.userInteraction(
      personId: personId,
      interactionType: interactionType,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          userInteractionState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(userInteractionState: CubitStates.success)),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // REGARD
  // ═══════════════════════════════════════════════════════════
  Future<void> sendRegard({required String personId}) async {
    emit(
      state.copyWith(sendRegardState: CubitStates.initial, errorMessage: null),
    );

    final result = await _repo.sendRegard(personId: personId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          sendRegardState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(sendRegardState: CubitStates.success)),
    );
  }

  Future<void> sendRegardText({
    required String personId,
    required String text,
  }) async {
    emit(
      state.copyWith(
        sendRegardTextState: CubitStates.initial,
        errorMessage: null,
      ),
    );

    final result = await _repo.sendRegard(personId: personId, text: text);

    result.fold(
      (failure) => emit(
        state.copyWith(
          sendRegardTextState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(state.copyWith(sendRegardTextState: CubitStates.success)),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOGGLE FAVORITE — القلب فقط
  // ═══════════════════════════════════════════════════════════
  Future<void> toggleLocalFavorite(String userId) async {
    final isCurrentlyFavorited = state.favoritedIds.contains(userId);
    final updatedFavorites = Set<String>.from(state.favoritedIds);

    if (isCurrentlyFavorited) {
      updatedFavorites.remove(userId);
    } else {
      updatedFavorites.add(userId);
    }

    // ✅ Optimistic update
    emit(state.copyWith(favoritedIds: updatedFavorites));

    final result = await _repo.toggleFavorite(
      userId: userId,
      isAdd: !isCurrentlyFavorited,
    );

    result.fold((failure) {
      // ❌ Revert on failure
      final revertFavorites = Set<String>.from(state.favoritedIds);
      if (isCurrentlyFavorited) {
        revertFavorites.add(userId);
      } else {
        revertFavorites.remove(userId);
      }
      emit(state.copyWith(favoritedIds: revertFavorites));
    }, (_) {});
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════
  void clampCurrentIndex({required int usersLength}) {
    if (usersLength <= 0) return;
    if (state.currentIndex >= usersLength) {
      emit(state.copyWith(currentIndex: usersLength - 1));
    }
  }

  void resetState() {
    emit(
      state.copyWith(
        userInteractionState: CubitStates.initial,
        sendRegardState: CubitStates.initial,
        sendRegardTextState: CubitStates.initial,
        errorMessage: null,
      ),
    );
  }

  // ✅ يُستخدم من MarriageBody لـ seed القلب عند الفتح من Interactions
  void seedFavorite(String userId) {
    if (state.favoritedIds.contains(userId)) return;
    final updated = Set<String>.from(state.favoritedIds)..add(userId);
    emit(state.copyWith(favoritedIds: updated));
  }

  @override
  Future<void> close() {
    _filterSubscription.cancel();
    _cardController?.removeListener(_onAnimationTick);
    _cardController?.dispose();
    return super.close();
  }
}