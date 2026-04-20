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
    final isDeactivated =
        prefs.getBool('marriage_section_deactivated') ?? false;
    final shouldBeVisible = !isDeactivated;

    // ⭐ فقط emit لو القيمة اتغيرت فعلاً
    if (state.isMarriageVisible != shouldBeVisible) {
      emit(state.copyWith(isMarriageVisible: shouldBeVisible));
    }
  }

  void changeIndex(int index) {
    // لو المستخدم بالفعل في نفس الصفحة وضغط عليها تاني (زي فيسبوك)
    if (state.currentIndex == index) {
      scrollToTop();
    } else {
      // ✅ لما تدخل marriage tab اخبي الـ nav فوراً
      // ✅ لما تخرج منه لأي tab تاني ورجّعه
      final hideNav = index == 1;
      emit(state.copyWith(currentIndex: index, isNavVisible: !hideNav));
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
    // ✅ الـ nav hide/show بيشتغل بس في marriage tab
    if (state.currentIndex != 1) return;
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
}
