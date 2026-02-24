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
    if (isDeactivated) {
      emit(state.copyWith(isMarriageVisible: false));
    }
  }

  void changeIndex(int index) {
    // لو المستخدم بالفعل في نفس الصفحة وضغط عليها تاني (زي فيسبوك)
    if (state.currentIndex == index && index == 0) {
      // Home index = 0
      scrollToTop();
    } else {
      emit(state.copyWith(currentIndex: index));
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
    final newIndex = (!isVisible && state.currentIndex == 1)
        ? 0
        : state.currentIndex;
    emit(state.copyWith(isMarriageVisible: isVisible, currentIndex: newIndex));
  }
}
