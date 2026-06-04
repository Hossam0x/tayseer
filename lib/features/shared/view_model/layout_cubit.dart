// features/advisor/layout/view_model/a_layout_cubit.dart
import 'dart:async';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/user_profile/user_profile_cubit.dart';
import 'package:tayseer/my_import.dart';

class LayoutCubit extends Cubit<LayoutState> {
  StreamSubscription<bool>? _marriageStatusSub;
  final tayseerSocketHelper _socketHelper;

  LayoutCubit({
    UserTypeEnum userType = UserTypeEnum.asConsultant,
    required tayseerSocketHelper socketHelper,
  }) : _socketHelper = socketHelper,
       super(LayoutState(userType: userType)) {
    _loadMarriageVisibility();
    _listenToMarriageStream();
    _setupGlobalSessionStartListener();
  }

  /// Subscribe to UserProfileCubit.marriageStatusStream so that when
  /// _loadInitialData() computes isMarriageDeactivated from the API and
  /// writes it to SharedPreferences, LayoutCubit reacts immediately —
  /// even on cold launch before the cache was populated.
  void _listenToMarriageStream() {
    _marriageStatusSub = UserProfileCubit.marriageStatusStream.stream.listen((
      isDeactivated,
    ) {
      updateMarriageVisibility(!isDeactivated);
    });
  }

  @override
  Future<void> close() {
    _marriageStatusSub?.cancel();
    _socketHelper.offAllForListener('LayoutCubit_sessionStarted');
    return super.close();
  }

  /// Setup global sessionStarted socket listener
  void _setupGlobalSessionStartListener() {
    _socketHelper.listenWithId('sessionStarted', 'LayoutCubit_sessionStarted', (
      data,
    ) {
      if (isClosed) return;

      try {
        final sessionId = data['sessionId'] as String? ?? '';
        final participantName = data['participant'] as String? ?? 'User';
        final duration = data['duration'] as int? ?? 0;
        final participantId = data['participantId'] as String? ?? '';

        // Emit event to trigger dialog in UI
        emit(
          state.copyWith(
            sessionStartData: {
              'sessionId': sessionId,
              'participantName': participantName,
              'duration': duration,
              'participantId': participantId,
            },
          ),
        );

        // Reset after a short delay
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!isClosed) {
            emit(state.copyWith(sessionStartData: null));
          }
        });
      } catch (e) {
        debugPrint('Error parsing sessionStarted event: $e');
      }
    });
  }

  Future<void> _loadMarriageVisibility() async {
    final prefs = await SharedPreferences.getInstance();

    // ✅ اقرأ الـ flag المحفوظ بعد الـ login
    final isFemaleMarried = prefs.getBool(kIsFemaleMarriedKey) ?? false;

    if (isFemaleMarried) {
      if (state.isMarriageVisible) {
        emit(state.copyWith(isMarriageVisible: false));
      }
      return;
    }

    final isDeactivated =
        prefs.getBool(kMarriageSectionDeactivatedKey) ?? false;
    final shouldBeVisible = !isDeactivated;

    if (state.isMarriageVisible != shouldBeVisible) {
      emit(state.copyWith(isMarriageVisible: shouldBeVisible));
    }
  }

  void changeIndex(int index) {
    if (state.currentIndex == index) {
      scrollToTop();
    } else {
      // ✅ دايماً ظهّر الـ nav عند تغيير الـ tab
      // marriage_body.dart هو اللي بيخبيه لو في users
      emit(state.copyWith(currentIndex: index, isNavVisible: true));
    }
  }

  void scrollToTop() {
    // نزود الـ trigger عشان الـ HomeViewBody يعرف إنه لازم يطلع لفوق
    emit(state.copyWith(scrollToTopTrigger: state.scrollToTopTrigger + 1));
  }

  void setNavVisibility(bool isVisible) {
    if (state.isNavVisible != isVisible) {
      emit(state.copyWith(isNavVisible: isVisible));
    }
  }

  void onScroll(bool isScrollingDown) {
    // ✅ home (0) و marriage (1) بس
    if (state.currentIndex != 0 && state.currentIndex != 1) return;
    if (isScrollingDown && state.isNavVisible) {
      setNavVisibility(false);
    } else if (!isScrollingDown && !state.isNavVisible) {
      setNavVisibility(true);
    }
  }

  void setHomeAtTop(bool isAtTop) {
    if (state.isHomeAtTop != isAtTop) {
      emit(state.copyWith(isHomeAtTop: isAtTop));
    }
  }

  void scrollToTopAndRefresh() {
    emit(
      state.copyWith(
        scrollToTopTrigger: state.scrollToTopTrigger + 1,
        refreshHomeTrigger: state.refreshHomeTrigger + 1,
      ),
    );
  }

  void changeUserType(UserTypeEnum userType) {
    emit(state.copyWith(userType: userType, currentIndex: 0));
  }

  void updateMarriageVisibility(bool isVisible) {
    // ⭐ لو القيمة نفسها، متعملش emit عشان متشغلش animation زيادة
    if (state.isMarriageVisible == isVisible) return;

    emit(
      state.copyWith(
        isMarriageVisible: isVisible,
        marriageToggleTrigger: state.marriageToggleTrigger + 1,
      ),
    );
  }

  /// ✅ استدعيها بعد الـ login مباشرة عشان تعيد حساب الـ marriage visibility
  Future<void> refreshMarriageVisibility() async {
    await _loadMarriageVisibility();
  }
}
