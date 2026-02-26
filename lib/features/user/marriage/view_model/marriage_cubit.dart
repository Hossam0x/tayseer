import 'package:tayseer/features/user/marriage/view_model/marriage_state.dart';
import 'package:tayseer/features/user/marriage/repositories/marriage_repository.dart';
import 'package:tayseer/my_import.dart';

class MarriageCubit extends Cubit<MarriageState> {
  MarriageCubit({MarriageRepository? repository})
    : _repo = repository ?? getIt<MarriageRepository>(),
      super(const MarriageState());
  final MarriageRepository _repo;
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

  /// Advance current profile index (wraps to 0 when reaches [usersLength]).
  void advanceProfile({required int usersLength}) {
    if (usersLength <= 0) return;
    final next = (state.currentIndex + 1) >= usersLength
        ? 0
        : (state.currentIndex + 1);
    emit(state.copyWith(currentIndex: next));
  }

  /// Clamp current index to valid range when users length changed.
  void clampCurrentIndex({required int usersLength}) {
    if (usersLength <= 0) return;
    if (state.currentIndex >= usersLength) {
      emit(state.copyWith(currentIndex: usersLength - 1));
    }
  }

  /// Update scrolling flag used by the UI for floating buttons.
  void setScrollingDown(bool isDown) {
    if (state.isScrollingDown == isDown) return;
    emit(state.copyWith(isScrollingDown: isDown));
  }

  /// Toggle which tab is shown (marriage vs interactions).
  void setMarriageTab(bool isMarriage) {
    if (state.isMarriageTab == isMarriage) return;
    emit(state.copyWith(isMarriageTab: isMarriage));
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
      (failure) {
        emit(
          state.copyWith(
            userInteractionState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(userInteractionState: CubitStates.success));
      },
    );
  }

  Future<void> sendRegard({required String personId}) async {
    emit(
      state.copyWith(sendRegardState: CubitStates.initial, errorMessage: null),
    );
    final result = await _repo.sendRegard(personId: personId);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            sendRegardState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(sendRegardState: CubitStates.success));
      },
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
      (failure) {
        emit(
          state.copyWith(
            sendRegardTextState: CubitStates.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(sendRegardTextState: CubitStates.success));
      },
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
}
