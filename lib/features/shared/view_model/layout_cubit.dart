// features/advisor/layout/view_model/a_layout_cubit.dart
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/my_import.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit({UserTypeEnum userType = UserTypeEnum.asConsultant})
    : super(LayoutState(userType: userType)) {
    _loadMarriageVisibility();
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
