// marriage_cubit.dart
import 'package:flutter/animation.dart';
import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageCubit extends Cubit<MarriageState> {
  MarriageCubit({MarriageRepository? repository})
    : _repo = repository ?? getIt<MarriageRepository>(),
      super(const MarriageState());

  final MarriageRepository _repo;

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

  // ═══ Swipe Actions ═══

  Future<void> swipeLike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;

    emit(state.copyWith(swipeDirection: 1, isAnimating: true));

    userInteraction(personId: personId, interactionType: 'like');

    await _cardController!.forward(from: 0);

    _onSwipeComplete(
      usersLength: usersLength,
      hasSinglePerson: hasSinglePerson,
    );
  }

  Future<void> swipeDislike({
    required String personId,
    required int usersLength,
    required bool hasSinglePerson,
  }) async {
    if (state.isAnimating || _cardController == null) return;

    emit(state.copyWith(swipeDirection: -1, isAnimating: true));

    userInteraction(personId: personId, interactionType: 'dislike');

    await _cardController!.forward(from: 0);

    _onSwipeComplete(
      usersLength: usersLength,
      hasSinglePerson: hasSinglePerson,
    );
  }

  void _onSwipeComplete({
    required int usersLength,
    required bool hasSinglePerson,
  }) {
    if (!hasSinglePerson && usersLength > 1) {
      advanceProfile(usersLength: usersLength);
    }

    _cardController!.value = 0;

    emit(
      state.copyWith(
        swipeDirection: 0,
        swipeProgress: 0,
        isAnimating: false,
        isScrollingDown: false,
      ),
    );
  }

  // ═══ History ═══

  void showHistoryView() {
    emit(state.copyWith(showHistory: true, selectedHistoryFilter: "liked_you"));
  }

  void hideHistoryView() {
    emit(state.copyWith(showHistory: false));
  }

  void setHistoryFilter(String filter) {
    emit(state.copyWith(selectedHistoryFilter: filter));
  }

  // ═══ باقي الميثودز زي ما هي ═══

  Future<void> fetchMarriageProfile() async {
    emit(
      state.copyWith(
        marriageProfileState: CubitStates.loading,
        errorMessage: null,
      ),
    );
    final result = await _repo.getMarriageProfile();
    result.fold(
      (failure) => emit(
        state.copyWith(
          marriageProfileState: CubitStates.failure,
          errorMessage: failure.message,
        ),
      ),
      (profile) => emit(
        state.copyWith(
          marriageProfileState: CubitStates.success,
          profile: profile,
          currentIndex: 0,
        ),
      ),
    );
  }

  void advanceProfile({required int usersLength}) {
    if (usersLength <= 0) return;
    final next = (state.currentIndex + 1) >= usersLength
        ? 0
        : (state.currentIndex + 1);
    emit(state.copyWith(currentIndex: next));
  }

  void clampCurrentIndex({required int usersLength}) {
    if (usersLength <= 0) return;
    if (state.currentIndex >= usersLength) {
      emit(state.copyWith(currentIndex: usersLength - 1));
    }
  }

  void setScrollingDown(bool isDown) {
    if (state.isScrollingDown == isDown) return;
    emit(state.copyWith(isScrollingDown: isDown));
  }

  void setMarriageTab(bool isMarriage) {
    if (state.isMarriageTab == isMarriage) return;
    if (state.showHistory) {
      emit(state.copyWith(showHistory: false, isMarriageTab: isMarriage));
    } else {
      emit(state.copyWith(isMarriageTab: isMarriage));
    }
  }

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

  @override
  Future<void> close() {
    _cardController?.removeListener(_onAnimationTick);
    _cardController?.dispose();
    return super.close();
  }
}
